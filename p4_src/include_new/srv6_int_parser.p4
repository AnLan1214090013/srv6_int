/*
 * Copyright 2017-present Open Networking Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* -*- P4_16 -*- */
#ifndef __SRV6_INT_PARSER__
#define __SRV6_INT_PARSER__


parser srv6_int_parser (
    packet_in packet,
    out headers_t hdr,
    inout local_metadata_t local_metadata,
    inout standard_metadata_t standard_metadata) {
    state start {
        transition select(standard_metadata.ingress_port) {
            CPU_PORT: parse_packet_out;
            default: parse_ethernet;
        }
    }

    state parse_packet_out {
        packet.extract(hdr.packet_out);
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type) {
            ETH_TYPE_IPV4 : parse_ipv4;
            ETH_TYPE_IPV6: parse_ipv6;
            default : accept;
        }
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol) {
            IP_PROTO_TCP : parse_tcp;
            IP_PROTO_UDP : parse_udp;
            default: accept;
        }
    }

    state parse_ipv6 {
        packet.extract(hdr.ipv6);
        local_metadata.ip_proto = hdr.ipv6.next_hdr;
        transition select(hdr.ipv6.next_hdr) {
            IP_PROTO_TCP: parse_tcp;
            IP_PROTO_UDP: parse_udp;
            IP_PROTO_SRV6: parse_srv6;
            default: accept;
        }
    }

    state parse_tcp {
        packet.extract(hdr.tcp);
        local_metadata.l4_src_port = hdr.tcp.src_port;
        local_metadata.l4_dst_port = hdr.tcp.dst_port;
        transition accept;
    }

    state parse_udp {
        packet.extract(hdr.udp);
        local_metadata.l4_src_port = hdr.udp.src_port;
        local_metadata.l4_dst_port = hdr.udp.dst_port;
        transition accept;
    }

    state parse_srv6 {
        packet.extract(hdr.srh);
        transition parse_segment_list;
    }
    state parse_segment_list {
        packet.extract(hdr.segment_list.next);
        bool next_sid = (bit<32>)hdr.srh.segment_left - 1 == (bit<32>)hdr.segment_list.lastIndex;
        transition select(next_sid){
            true: mark_next_sid;
            default: check_last_sid;
        }
    }

    state mark_next_sid{
        local_metadata.next_sid = hdr.segment_list.last.sid;
        transition check_last_sid;
    }

    state check_last_sid {
        bool last_sid = (bit<32>)hdr.srh.last_entry == (bit<32>)hdr.segment_list.lastIndex;
        transition select(last_sid){
            true: parse_srv6_next_hdr;
            false: parse_segment_list;
        }
    }

    state parse_srv6_next_hdr{
        transition select(hdr.srh.next_hdr){
            IP_PROTO_TCP: parse_tcp;
            PROTO_INT: parse_count;
            IP_PROTO_UDP: parse_udp;
            default: accept;
        }
    }

    //int
    state parse_count{
        packet.extract(hdr.nodeCount);
        local_metadata.parser_metadata.remaining = hdr.nodeCount.count;
        transition select(local_metadata.parser_metadata.remaining) {
            0 : accept;
            default: parse_int;
        }
    }

    state parse_int {
        packet.extract(hdr.INT.next);
        local_metadata.parser_metadata.remaining = local_metadata.parser_metadata.remaining  - 1;
        transition select(local_metadata.parser_metadata.remaining) {
            0 : accept;
            default: parse_int;
        }
    } 

}



control srv6_int_deparser(
    packet_out packet,
    in headers_t hdr) {
    apply {
        packet.emit(hdr.packet_in);
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.tcp);
        packet.emit(hdr.udp);

        //srv6
        packet.emit(hdr.ipv6);
        packet.emit(hdr.srh);
        packet.emit(hdr.segment_list);

        //int
        packet.emit(hdr.nodeCount);
        packet.emit(hdr.INT);   
    }
}


#endif
