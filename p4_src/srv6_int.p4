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
#include <core.p4>
#include <v1model.p4>
#include "include_new/defines.p4"
#include "include_new/headers.p4"
#include "include_new/actions.p4"
#include "include_new/checksums.p4"
#include "include_new/srv6_int_parser.p4"
#include "include_new/srv6_int_transit.p4"


control snt_ingress (
    inout headers_t hdr,
    inout local_metadata_t local_metadata,
    inout standard_metadata_t standard_metadata) {

    apply {
        srv6_int_ingress.apply(hdr, local_metadata, standard_metadata);
    }
}

control snt_egress (
    inout headers_t hdr,
    inout local_metadata_t local_metadata,
    inout standard_metadata_t standard_metadata) {

    apply {
        srv6_int_egress.apply(hdr, local_metadata, standard_metadata);
    }
}

V1Switch(
    srv6_int_parser(),
    verify_checksum_control(),
    snt_ingress(),
    snt_egress(),
    compute_checksum_control(),
    srv6_int_deparser()
) main;
