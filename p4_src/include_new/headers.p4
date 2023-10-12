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

#ifndef __HEADERS__
#define __HEADERS__

#include "defines.p4"

@controller_header("packet_in")
header packet_in_header_t {
    bit<9> ingress_port;
    bit<7> pad;
}

@controller_header("packet_out")
header packet_out_header_t {
    bit<9> egress_port;
    bit<7> pad;
}

header ethernet_t {
    bit<48> dst_addr;
    bit<48> src_addr;
    bit<16> ether_type;
}

header ipv4_t {
    bit<4>  version;
    bit<4>  ihl;
    bit<6>  dscp;
    bit<2>  ecn;
    bit<16> len;
    bit<16> identification;
    bit<3>  flags;
    bit<13> frag_offset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdr_checksum;
    bit<32> src_addr;
    bit<32> dst_addr;
}

header tcp_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<32> seq_no;
    bit<32> ack_no;
    bit<4>  data_offset;
    bit<3>  res;
    bit<3>  ecn;
    bit<6>  ctrl;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgent_ptr;
}

header udp_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<16> length_;
    bit<16> checksum;
}


// SRV6 headers
header ipv6_t{
    bit<4> version;
    bit<8> traffic_class;
    bit<20> flow_label;
    bit<16> payload_len;
    bit<8> next_hdr;
    bit<8> hop_limit;
    bit<128> src_addr;
    bit<128> dst_addr;
}

header srv6_header_t{
    bit<8> next_hdr;
    bit<8> hdr_ext_len;
    bit<8> routing_type;
    bit<8> segment_left;
    bit<8> last_entry;
    bit<8> flags;
    bit<16> tag;
}

header srv6_segment_list_t{
    bit<128> sid; 
}

//int header
header int_t {
    switchID_t swid;
    ingress_port_t ingress_port;
    egress_port_t egress_port;
    egressSpec_t egress_spec;
    ingress_global_timestamp_t ingress_global_timestamp;
    egress_global_timestamp_t egress_global_timestamp;
    enq_timestamp_t enq_timestamp;
    enq_qdepth_t enq_qdepth;
    deq_timedelta_t deq_timedelta;
    deq_qdepth_t deq_qdepth;
}
header nodeCount_t{
    bit<16>  count;
}

struct ingress_metadata_t {
    bit<16>  count;
}

struct parser_metadata_t {
    bit<16>  remaining;
}


struct headers_t {
    packet_out_header_t packet_out;
    packet_in_header_t packet_in;
    
    // Original packet's headers
    ethernet_t ethernet;
    ipv4_t ipv4;
    tcp_t tcp;
    udp_t udp;
    
    //srv6
    ipv6_t ipv6;
    srv6_header_t srh;
    srv6_segment_list_t[SRV6_MAX_HOPS] segment_list;

    //int
    nodeCount_t nodeCount;
    int_t[SRV6_MAX_HOPS] INT;
}

struct local_metadata_t {
    bit<16>       l4_src_port;
    bit<16>       l4_dst_port;
    //srv6
    ipv6_addr_t next_sid;
    bit<8>         ip_proto;
    //int
    ingress_metadata_t   ingress_metadata;
    parser_metadata_t   parser_metadata;
}



#endif
