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

#ifndef __SRV6_INT_TRANSIT__
#define __SRV6_INT_TRANSIT__

#include "headers.p4"
#include "defines.p4"

control srv6_int_ingress(inout headers_t hdr,
                inout local_metadata_t local_metadata,
                inout standard_metadata_t standard_metadata) {


    action drop(){
    	mark_to_drop(standard_metadata);
    }

    table local_mac_table {

    	key = {
    		hdr.ethernet.dst_addr: exact;
    	}
    	actions = {
    		NoAction;
    	}
    }


    action set_next_hop(mac_addr_t dmac, port_t port){
    	hdr.ethernet.src_addr = hdr.ethernet.dst_addr;
    	hdr.ethernet.dst_addr = dmac;
    	hdr.ipv6.hop_limit = hdr.ipv6.hop_limit - 1;
    	standard_metadata.egress_spec = port;
    }

    table routing_v6_table {
    	key = {
    		hdr.ipv6.dst_addr: lpm;
    	}
    	actions = {
    		set_next_hop;
    	}
    }


    action end(){
        hdr.srh.segment_left = hdr.srh.segment_left - 1;
        hdr.ipv6.dst_addr = local_metadata.next_sid;
    }

    table local_sid_table {
    	key = {
    		hdr.ipv6.dst_addr: lpm;
    	}
    	actions = {
    		end;
    	}

    }

    action insert_srh(bit<8> num_segments){
        hdr.srh.setValid();
        // hdr.srh.next_hdr = hdr.ipv6.next_hdr;
        hdr.srh.next_hdr = PROTO_INT;
        hdr.srh.hdr_ext_len = num_segments * 2;
        hdr.srh.routing_type = 4;
        hdr.srh.segment_left = num_segments - 1;
        hdr.srh.last_entry = num_segments - 1;
        hdr.srh.flags = 0;
        hdr.srh.tag = 0;
        hdr.ipv6.next_hdr = IP_PROTO_SRV6;
    }

    action insert_segment_list_1(ipv6_addr_t s1){
        hdr.ipv6.dst_addr = s1;
        hdr.ipv6.payload_len = hdr.ipv6.payload_len + 24;
        insert_srh(1);
        hdr.segment_list[0].setValid();
        hdr.segment_list[0].sid = s1;
    }

    action insert_segment_list_2(ipv6_addr_t s1, ipv6_addr_t s2){
        hdr.ipv6.dst_addr = s1;
        hdr.ipv6.payload_len = hdr.ipv6.payload_len + 40;
        insert_srh(2);
        hdr.segment_list[0].setValid();
        hdr.segment_list[0].sid = s2;
        hdr.segment_list[1].setValid();
        hdr.segment_list[1].sid = s1;
    }

    action insert_segment_list_3(ipv6_addr_t s1, ipv6_addr_t s2, ipv6_addr_t s3){
        hdr.ipv6.dst_addr = s1;
        hdr.ipv6.payload_len = hdr.ipv6.payload_len + 56;
        insert_srh(3);
        hdr.segment_list[0].setValid();
        hdr.segment_list[0].sid = s3;
        hdr.segment_list[1].setValid();
        hdr.segment_list[1].sid = s2;
        hdr.segment_list[2].setValid();
        hdr.segment_list[2].sid = s1;
    }

    action insert_segment_list_4(ipv6_addr_t s1, ipv6_addr_t s2, ipv6_addr_t s3, ipv6_addr_t s4){
        hdr.ipv6.dst_addr = s1;
        hdr.ipv6.payload_len = hdr.ipv6.payload_len + 72;
        insert_srh(4);
        hdr.segment_list[0].setValid();
        hdr.segment_list[0].sid = s4;
        hdr.segment_list[1].setValid();
        hdr.segment_list[1].sid = s3;
        hdr.segment_list[2].setValid();
        hdr.segment_list[2].sid = s2;
        hdr.segment_list[3].setValid();
        hdr.segment_list[3].sid = s1;

    }


    table transit_table{
    	key={
    		hdr.ipv6.dst_addr: lpm;
    	}
    	actions = {
            insert_segment_list_1;
    		insert_segment_list_2;
    		insert_segment_list_3;
            insert_segment_list_4;
    	}
    }

    action srv6_pop(){
        hdr.ipv6.next_hdr = hdr.srh.next_hdr;
        bit<16> srh_size = (((bit<16>)hdr.srh.last_entry + 1) << 4) + 8;
        // hdr.ipv6.payload_len = hdr.ipv6.payload_len - srh_size;

        // hdr.srh.setInvalid();
        // hdr.segment_list[0].setInvalid();
        // hdr.segment_list[1].setInvalid();
        // hdr.segment_list[2].setInvalid();
        // hdr.segment_list[3].setInvalid();
        // hdr.segment_list[4].setInvalid();
        // hdr.segment_list[5].setInvalid();
    }

    //int
    action set_next_int_header(){
        hdr.srh.next_hdr = PROTO_INT;
    }

    apply {
        
        set_next_int_header();
        if (standard_metadata.ingress_port == CPU_PORT) {
        	// Receive packets from controller, namely packet_out message.
        	// Directly tell switch where the port packets sent to.

        	standard_metadata.egress_spec = hdr.packet_out.egress_port;

        	// pop the header of packet-out packet

        	hdr.packet_out.setInvalid();
        	exit;
        }


        // The logic of how to handle srv6 header
        // simple version, only considering ipv6 packets and srv6 packets
		//当交换机接收到到达自己的报文时，检查其mac地址、检查是否是end节点和源节点，进行相应的操作，然后进行ipv6的转发
    	if(local_mac_table.apply().hit){
    		if(hdr.ipv6.isValid()){
    			if(local_sid_table.apply().hit){
    				if(hdr.srh.isValid() && hdr.srh.segment_left == 0){
    					srv6_pop();
    				}
    			}else{
    				transit_table.apply();
    			}

                

    			routing_v6_table.apply();

    			if(hdr.ipv6.hop_limit == 0){
    				drop();
    			}
    		}

    	}

     }
}

control srv6_int_egress(inout headers_t hdr,
               inout local_metadata_t local_metadata,
               inout standard_metadata_t standard_metadata) {

    action add_swtrace(switchID_t swid) { 
        hdr.nodeCount.count = hdr.nodeCount.count + 1;
        hdr.INT.push_front(1);
        hdr.INT[0].setValid();
        hdr.INT[0].swid = swid;
        hdr.INT[0].ingress_port = (ingress_port_t)standard_metadata.ingress_port;
        hdr.INT[0].ingress_global_timestamp = (ingress_global_timestamp_t)standard_metadata.ingress_global_timestamp;
        hdr.INT[0].egress_port = (egress_port_t)standard_metadata.egress_port;
        hdr.INT[0].egress_spec = (egressSpec_t)standard_metadata.egress_spec;
        hdr.INT[0].egress_global_timestamp = (egress_global_timestamp_t)standard_metadata.egress_global_timestamp;
        hdr.INT[0].enq_timestamp = (enq_timestamp_t)standard_metadata.enq_timestamp;
        hdr.INT[0].enq_qdepth = (enq_qdepth_t)standard_metadata.enq_qdepth;
        hdr.INT[0].deq_timedelta = (deq_timedelta_t)standard_metadata.deq_timedelta;
        hdr.INT[0].deq_qdepth = (deq_qdepth_t)standard_metadata.deq_qdepth;
        
        // hdr.ipv4.totalLen = hdr.ipv4.totalLen + 32;
    }

    table swtrace {
        actions = { 
	        add_swtrace; 
	        NoAction; 
        }
        default_action = NoAction();      
    }

    apply {
        if (standard_metadata.egress_port == CPU_PORT) {
        	// Handle packet-in packet, if egress_port is cpu port, which means this packet is sent to controller
            // Add the packet-in header

            hdr.packet_in.setValid();
            hdr.packet_in.ingress_port = standard_metadata.ingress_port;

        }  
        if (hdr.nodeCount.isValid()) {
            swtrace.apply();
        }  
    }
}



#endif