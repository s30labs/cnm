<?php
      $TIPS[]=array(
         'id_ref' => 'airspace_nclients',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>bsnAPIfLoadNumOfClients</strong> a partir de los siguientes atributos de la mib AIRESPACE-WIRELESS-MIB:<br><br><strong>AIRESPACE-WIRELESS-MIB::bsnAPIfLoadNumOfClients (GAUGE):</strong> "This is the number of clients attached to this Airespace 
               AP at the last measurement interval(This comes from 
               APF)"
',
      );


      $TIPS[]=array(
         'id_ref' => 'airspace_ap_status',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>bsnAPOperationStatus|bsnAPAdminStatus</strong> a partir de los siguientes atributos de la mib AIRESPACE-WIRELESS-MIB:<br><br><strong>AIRESPACE-WIRELESS-MIB::bsnAPOperationStatus (GAUGE):</strong> "Operation State of the AP. When AP associates with the 
          Airespace Switch its state will be associated. When Airespace
          AP is disassociated from the Switch, its state will be 
          disassociating. The state is downloading when the AP is 
          downloading its firmware."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPAdminStatus (GAUGE):</strong> "Admin State of the AP"
',
      );


      $TIPS[]=array(
         'id_ref' => 'airspace_ap_profiles',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>bsnAPIfLoadProfileState|bsnAPIfInterferenceProfileState|bsnAPIfNoiseProfileState|bsnAPIfCoverageProfileState</strong> a partir de los siguientes atributos de la mib AIRESPACE-WIRELESS-MIB:<br><br><strong>AIRESPACE-WIRELESS-MIB::bsnAPIfLoadProfileState (GAUGE):</strong> "This field represents the current state of the LOAD
                monitor. This is a total measurement of the business of
                this Airespace AP. PASS indicates that this Airespace 
                AP is performing adequately compared to the Airespace 
                AP profile. FAIL indicates the Airespace AP is not
                performing adequately against the LOAD profile."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfInterferenceProfileState (GAUGE):</strong> "This field represents the current state of Interference
               monitor. This is a total measurement of the interference
               present at this Airespace AP. PASS indicates that this 
               Airespace AP is performing adequately compared to the 
               Interference profile.  FAIL indicates the Airespace AP 
               is not performing adequately against the Interference 
               profile."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfNoiseProfileState (GAUGE):</strong> "This field represents the current state of Noise
              monitor. This is a total measurement of the noise
              present at this Airespace AP. PASS indicates that this 
              Airespace AP is performing adequately compared to the 
              noise profile.
              FAIL indicates the Airespace AP is not performing 
              adequately against the noise profile."
<strong>AIRESPACE-WIRELESS-MIB::bsnAPIfCoverageProfileState (GAUGE):</strong> "This field represents the current state of coverage
                 monitor. This is a total measurement of the client 
                 coverage at this Airespace AP. PASS indicates that 
                 this  Airespace AP is performing adequately compared 
                 to the  coverage profile. FAIL indicates the Airespace
                 AP is not performing adequately against the coverage 
                 profile."
',
      );


?>
