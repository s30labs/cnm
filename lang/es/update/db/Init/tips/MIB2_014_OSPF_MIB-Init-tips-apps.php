<?
	$TIPS[]=array(
		'id_ref' => 'app_mib2_ospf_areas_table',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra la tabla de areas OSPF del equipo</strong><br>Utiliza la tabla SNMP OSPF-MIB::ospfAreaTable (Enterprise=00000)<br><br><strong>OSPF-MIB::ospfAuthType (GAUGE):</strong><br>"The authentication type specified for an area.
            Additional authentication types may be assigned
            locally on a per Area basis."
   DEFVAL	{ 0 }
<strong>OSPF-MIB::ospfImportAsExtern (GAUGE):</strong><br>"The areas support for importing  AS  external
            link- state advertisements."
   DEFVAL	{ importExternal }
<strong>OSPF-MIB::ospfSpfRuns (COUNTER):</strong><br>"The number of times that the intra-area  route
            table  has  been  calculated  using this areas
            link-state database.  This  is  typically  done
            using Dijkstras algorithm."
<strong>OSPF-MIB::ospfAreaBdrRtrCount (GAUGE):</strong><br>"The total number of area border routers reach-
            able within this area.  This is initially zero,
            and is calculated in each SPF Pass."
<strong>OSPF-MIB::ospfAsBdrRtrCount (GAUGE):</strong><br>"The total number of Autonomous  System  border
            routers  reachable  within  this area.  This is
            initially zero, and is calculated in  each  SPF
            Pass."
<strong>OSPF-MIB::ospfAreaLsaCount (GAUGE):</strong><br>"The total number of link-state  advertisements
            in  this  areas link-state database, excluding
            AS External LSAs."
<strong>OSPF-MIB::ospfAreaLsaCksumSum (GAUGE):</strong><br>"The 32-bit unsigned sum of the link-state  ad-
            vertisements  LS  checksums  contained in this
            areas link-state database.  This sum  excludes
            external (LS type 5) link-state advertisements.
            The sum can be used to determine if  there  has
            been  a  change  in a routers link state data-
            base, and to compare the link-state database of
 
            two routers."
   DEFVAL	{ 0 }
<strong>OSPF-MIB::ospfAreaSummary (GAUGE):</strong><br>"The variable ospfAreaSummary controls the  im-
            port  of  summary LSAs into stub areas.  It has
            no effect on other areas.
 
            If it is noAreaSummary, the router will neither
            originate  nor  propagate summary LSAs into the
            stub area.  It will rely entirely  on  its  de-
            fault route.
 
            If it is sendAreaSummary, the router will  both
            summarize and propagate summary LSAs."
   DEFVAL	{ noAreaSummary }
<strong>OSPF-MIB::ospfAreaStatus (GAUGE):</strong><br>"This variable displays the status of  the  en-
            try.  Setting it to invalid has the effect of
            rendering it inoperative.  The internal  effect
            (row removal) is implementation dependent."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_mib2_ospf_interfaces_table',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra la tabla de interfaces de desde el punto de vista del protocolo OSPF</strong><br>Utiliza la tabla SNMP OSPF-MIB::ospfIfTable (Enterprise=00000)<br><br><strong>OSPF-MIB::ospfIfIpAddress (GAUGE):</strong><br>"The IP address of this OSPF interface."
<strong>OSPF-MIB::ospfAddressLessIf (GAUGE):</strong><br>"For the purpose of easing  the  instancing  of
            addressed   and  addressless  interfaces;  This
            variable takes the value 0 on  interfaces  with
            IP  Addresses,  and  the corresponding value of
            ifIndex for interfaces having no IP Address."
<strong>OSPF-MIB::ospfIfAreaId (GAUGE):</strong><br>"A 32-bit integer uniquely identifying the area
            to  which  the  interface  connects.   Area  ID
            0.0.0.0 is used for the OSPF backbone."
   DEFVAL	{ 0 }
<strong>OSPF-MIB::ospfIfType (GAUGE):</strong><br>"The OSPF interface type.
 
            By way of a default, this field may be intuited
            from the corresponding value of ifType.  Broad-
            cast LANs, such as  Ethernet  and  IEEE  802.5,
            take  the  value  broadcast, X.25 and similar
            technologies take the value nbma,  and  links
            that  are  definitively point to point take the
            value pointToPoint."
<strong>OSPF-MIB::ospfIfAdminStat (GAUGE):</strong><br>"The OSPF  interfaces  administrative  status.
            The  value formed on the interface, and the in-
            terface will be advertised as an internal route
            to  some  area.   The  value disabled denotes
            that the interface is external to OSPF."
   DEFVAL	{ enabled }
<strong>OSPF-MIB::ospfIfRtrPriority (GAUGE):</strong><br>"The  priority  of  this  interface.   Used  in
            multi-access  networks,  this  field is used in
            the designated router election algorithm.   The
            value 0 signifies that the router is not eligi-
            ble to become the  designated  router  on  this
            particular  network.   In the event of a tie in
            this value, routers will use their Router ID as
            a tie breaker."
   DEFVAL	{ 1 }
<strong>OSPF-MIB::ospfIfTransitDelay (GAUGE):</strong><br>"The estimated number of seconds  it  takes  to
            transmit  a  link state update packet over this
            interface."
   DEFVAL	{ 1 }
<strong>OSPF-MIB::ospfIfRetransInterval (GAUGE):</strong><br>"The number of seconds between  link-state  ad-
            vertisement  retransmissions,  for  adjacencies
            belonging to this  interface.   This  value  is
            also used when retransmitting database descrip-
            tion and link-state request packets."
   DEFVAL	{ 5 }
<strong>OSPF-MIB::ospfIfHelloInterval (GAUGE):</strong><br>"The length of time, in  seconds,  between  the
            Hello  packets that the router sends on the in-
 
            terface.  This value must be the same  for  all
            routers attached to a common network."
   DEFVAL	{ 10 }
<strong>OSPF-MIB::ospfIfRtrDeadInterval (GAUGE):</strong><br>"The number of seconds that  a  routers  Hello
            packets  have  not been seen before its neigh-
            bors declare the router down.  This  should  be
            some  multiple  of  the  Hello  interval.  This
            value must be the same for all routers attached
            to a common network."
   DEFVAL	{ 40 }
<strong>OSPF-MIB::ospfIfPollInterval (GAUGE):</strong><br>"The larger time interval, in seconds,  between
            the  Hello  packets  sent  to  an inactive non-
            broadcast multi- access neighbor."
   DEFVAL	{ 120 }
<strong>OSPF-MIB::ospfIfState (GAUGE):</strong><br>"The OSPF Interface State."
   DEFVAL	{ down }
<strong>OSPF-MIB::ospfIfDesignatedRouter (GAUGE):</strong><br>"The IP Address of the Designated Router."
   DEFVAL	{ 0 }
<strong>OSPF-MIB::ospfIfBackupDesignatedRouter (GAUGE):</strong><br>"The  IP  Address  of  the  Backup   Designated
            Router."
   DEFVAL	{ 0 }
<strong>OSPF-MIB::ospfIfEvents (COUNTER):</strong><br>"The number of times this  OSPF  interface  has
            changed its state, or an error has occurred."
<strong>OSPF-MIB::ospfIfAuthKey (GAUGE):</strong><br>"The Authentication Key.  If the Areas Author-
            ization  Type  is  simplePassword,  and the key
            length is shorter than 8 octets, the agent will
            left adjust and zero fill to 8 octets.
 
            Note that unauthenticated  interfaces  need  no
            authentication key, and simple password authen-
            tication cannot use a key of more  than  8  oc-
            tets.  Larger keys are useful only with authen-
            tication mechanisms not specified in this docu-
 
            ment.
 
            When read, ospfIfAuthKey always returns an  Oc-
            tet String of length zero."
   DEFVAL	{ 0 }
<strong>OSPF-MIB::ospfIfStatus (GAUGE):</strong><br>"This variable displays the status of  the  en-
            try.  Setting it to invalid has the effect of
            rendering it inoperative.  The internal  effect
            (row removal) is implementation dependent."
<strong>OSPF-MIB::ospfIfMulticastForwarding (GAUGE):</strong><br>"The way multicasts should  forwarded  on  this
            interface;  not  forwarded,  forwarded  as data
            link multicasts, or forwarded as data link uni-
            casts.   Data link multicasting is not meaning-
            ful on point to point and NBMA interfaces,  and
            setting ospfMulticastForwarding to 0 effective-
            ly disables all multicast forwarding."
   DEFVAL	{ blocked }
<strong>OSPF-MIB::ospfIfDemand (GAUGE):</strong><br>"Indicates whether Demand OSPF procedures (hel-
 
            lo supression to FULL neighbors and setting the
            DoNotAge flag on proogated LSAs) should be per-
            formed on this interface."
   DEFVAL	{ false }
<strong>OSPF-MIB::ospfIfAuthType (GAUGE):</strong><br>"The authentication type specified for  an  in-
            terface.   Additional  authentication types may
            be assigned locally."
   DEFVAL	{ 0 }
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_mib2_ospf_neighbourss_table',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra la tabla de vecinos del equipo desde el punto de vista del protocolo OSPF</strong><br>Utiliza la tabla SNMP OSPF-MIB::ospfNbrTable (Enterprise=00000)<br><br><strong>OSPF-MIB::ospfNbrIpAddr (GAUGE):</strong><br>"The IP address this neighbor is using  in  its
            IP  Source  Address.  Note that, on addressless
            links, this will not be 0.0.0.0,  but  the  ad-
            dress of another of the neighbors interfaces."
<strong>OSPF-MIB::ospfNbrAddressLessIndex (GAUGE):</strong><br>"On an interface having an  IP  Address,  zero.
            On  addressless  interfaces,  the corresponding
            value of ifIndex in the Internet Standard  MIB.
            On  row  creation, this can be derived from the
            instance."
<strong>OSPF-MIB::ospfNbrRtrId (GAUGE):</strong><br>"A 32-bit integer (represented as a type  IpAd-
            dress)  uniquely  identifying  the  neighboring
            router in the Autonomous System."
   DEFVAL	{ 0 }
<strong>OSPF-MIB::ospfNbrOptions (GAUGE):</strong><br>"A Bit Mask corresponding to the neighbors op-
            tions field.
 
            Bit 0, if set, indicates that the  system  will
            operate  on  Type of Service metrics other than
            TOS 0.  If zero, the neighbor will  ignore  all
            metrics except the TOS 0 metric.
 
            Bit 1, if set, indicates  that  the  associated
            area  accepts and operates on external informa-
            tion; if zero, it is a stub area.
 
            Bit 2, if set, indicates that the system is ca-
            pable  of routing IP Multicast datagrams; i.e.,
            that it implements the Multicast Extensions  to
            OSPF.
 
            Bit 3, if set, indicates  that  the  associated
            area  is  an  NSSA.  These areas are capable of
            carrying type 7 external advertisements,  which
            are  translated into type 5 external advertise-
 
            ments at NSSA borders."
   DEFVAL	{ 0 }
<strong>OSPF-MIB::ospfNbrPriority (GAUGE):</strong><br>"The priority of this neighbor in the designat-
            ed router election algorithm.  The value 0 sig-
            nifies that the neighbor is not eligible to be-
            come  the  designated router on this particular
            network."
   DEFVAL	{ 1 }
<strong>OSPF-MIB::ospfNbrState (GAUGE):</strong><br>"The State of the relationship with this Neigh-
            bor."
   DEFVAL	{ down }
<strong>OSPF-MIB::ospfNbrEvents (COUNTER):</strong><br>"The number of times this neighbor relationship
            has changed state, or an error has occurred."
<strong>OSPF-MIB::ospfNbrLsRetransQLen (GAUGE):</strong><br>"The  current  length  of  the   retransmission
            queue."
<strong>OSPF-MIB::ospfNbmaNbrStatus (GAUGE):</strong><br>"This variable displays the status of  the  en-
            try.  Setting it to invalid has the effect of
            rendering it inoperative.  The internal  effect
            (row removal) is implementation dependent."
<strong>OSPF-MIB::ospfNbmaNbrPermanence (GAUGE):</strong><br>"This variable displays the status of  the  en-
            try.   dynamic  and  permanent refer to how
            the neighbor became known."
   DEFVAL	{ permanent }
<strong>OSPF-MIB::ospfNbrHelloSuppressed (GAUGE):</strong><br>"Indicates whether Hellos are being  suppressed
 
            to the neighbor"
',
	);

?>
