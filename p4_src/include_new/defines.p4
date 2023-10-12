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

#ifndef __DEFINES__
#define __DEFINES__

#define ETH_TYPE_IPV4 0x0800
#define IP_PROTO_TCP 8w6
#define IP_PROTO_UDP 8w17

#define MAX_PORTS 511

//srv6
#define ETH_TYPE_IPV6 0x86dd

//int
#define PROTO_INT 253

typedef bit<48> mac_t;
typedef bit<32> ip_address_t;
typedef bit<16> l4_port_t;
typedef bit<9>  port_t;
typedef bit<16> next_hop_id_t;

//srv6
typedef bit<128> ipv6_addr_t;
typedef bit<48> mac_addr_t;

//int 
typedef bit<31> switchID_t;
typedef bit<9> ingress_port_t;
typedef bit<9> egress_port_t;
typedef bit<9>  egressSpec_t;
typedef bit<48>  ingress_global_timestamp_t;
typedef bit<48>  egress_global_timestamp_t;
typedef bit<32>  enq_timestamp_t;
typedef bit<19> enq_qdepth_t;
typedef bit<32> deq_timedelta_t;
typedef bit<19> deq_qdepth_t;

const port_t CPU_PORT = 255;

#define PKT_INSTANCE_TYPE_NORMAL 0
#define PKT_INSTANCE_TYPE_INGRESS_CLONE 1
#define PKT_INSTANCE_TYPE_EGRESS_CLONE 2
#define PKT_INSTANCE_TYPE_COALESCED 3
#define PKT_INSTANCE_TYPE_INGRESS_RECIRC 4
#define PKT_INSTANCE_TYPE_REPLICATION 5
#define PKT_INSTANCE_TYPE_RESUBMIT 6

//srv6 defines
#define SRV6_MAX_HOPS 6
#define IP_PROTO_SRV6 8w43

#endif
