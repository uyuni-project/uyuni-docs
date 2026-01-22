- Documented Debian 13 as supported client
- Document openSUSE Leap 15.6 and SUSE Linux Enterprise 16 as supported clients
- Included global GPG decryption for pillar data in specialized guide (bsc#1255743)
- Added separate procedure for reenabling router advertisements (bsc#1254259)
- Changed instructions from provate to public key in Admintration Guide
  (bsc#1254585)
- Update and clarify Retail formulas page
- Document formula images on air-gapped systems
- CIS removed from list of supported OpenSCAP profiles
- Added missing optional parameter in server rename command (bsc#1256066)
- Changes example for the third-party repository GPG keys (bsc#1255857)
- Added documentation for Access Group Management to Reference Guide
- Updated HUB XML-RPC API to use SSL connection in Specialized Guides
- Documented openSUSE Leap 15.6 and SUSE Linux Enterprise 16 as supported
  clients
- Fixed the path to the certificates in proxy deployment
- Fixed issue for third-party certificates during migration (bsc#1253350)
- Explained how to generate the DB certificate for the upgrade of a 5.0
  peripheral server (bsc#1248282)
- Explained how to generate the proxy certificates on a peripheral server
  (bsc#1249425)
- Fixed the issue with importing SSL certificates in Administration Guide 
  (bsc#1253382)
- Added precisions on the intermediate CA certificates to Administration
  Guide (bsc#1253735)
- Improved procedure formatting for better clarity in Administration
  Guide (bsc#1253660)
- Added missing options to command example in Installation and
- Added links to man pages for createrepo_c and reprepro to
  Administration Guide (bsc#1237181)
- Added documentation for new spacecmd subcommand system_needrebootafterupdate
  to Reference Guide
- Added missing options to command example in Installation and 
  Upgrade Guide (bsc#1252908)
- Added non-SUSE URLs to requirements in installation and Upgrade
  Guide (bsc#1252665)
- Fixed PAYG documentation to reflect the changes in providing support
  (bsc#1252869)
- Fixed typo for command options in Reference Guide (bsc#1253174)
- Added additional step for client deletion in Client Configuration
  Guide (bsc#1253249)
- Fixed wrong --ssl-db-server-{cert|key} parameters in Specialized Guides
  (bsc#1249462)
- Clarified server config option for spacemd in Refrence Guide
  (bsc#1253197)
- Changed the installation instructions to use product instead of packages 
  (bsc#1249041)
- Added instructions to clean unused container images after upgrade
  (bsc#1253022)
- Clarified the instructions that needs to run in container (bsc#1252680)
- Information about mirroring Ubuntu ESM packages will be limited to Uyuni.
  This is to eliminate confusion about which features and packages are supported
  within SUSE Multi-Linux manager offering.
- Fixed the proxy timeout procedure in Administration Guide (bsc#1252020)
- Fixed the file name in the provided example in Administration
  Guide (bsc#1252727)
- Improved section about Saline deployment in Specialized Guides (bsc#1252637)
- Fix volumes, ports and air-gapped install after database split
- Added troubleshooting section for mass duplicate machine_id
- Improved recommendation in Large Deployments Guide (bsc#1252723)
- Added Tumbleweed migration for Uyuni
- Updated and corrected the migration instructions for
  server and proxy in Installation and Upgrade Guide
- Added SSL certificates requirement before migrations
- Removed the option of editing the sshd_config file to
  enable root login (bsc#1252106)
- Added conditional logic for Uyuni licensing
- Fixed unterminated listing blocks across multiple documents
- Corrected table formatting issues in both Korean and English versions
- Moved snippets to the partials directory for proper inclusion 
  and reuse
- Added instructions for firewall settings in Administration Guide
- Corected the procedure instruction in Administration Guide (bsc#1252023)
- Improved documentation about monitoring in Administration Guide
- Documented how to disable HSTS in Administration Guide
- Removed virtualization from documentation (bsc#1246983)
- Fixed instruction and command in Client Configuration Guide
  (bsc#1248803)
- Added openSUSE Tumbleweed support for Uyuni
- Documented the new autoinstallation snippets (bsc#1194792)
- Improved the appearance of Web UI instructions in Administration
  Guide (bsc#1250451)
- Improved example for proxy bootstrap script in Client Configuration 
  Guide (bsc#1251117)
- Corrected the images files location in Administration guide
  (bsc#1249384)
- Added new workflow for liberating RHEL server in Common Workflows 
  Guides (bsc#1250423)
- Fixed the broken link in Specialized Guides (bsc#1249073)
- Enhanced file location information in Administration Guide
  (bsc#1250364)
- Added note for the upgrade with third-party SSL certificates to 
  Installation and Upgrade Guide
- Corrected invalid command parameters in Specialized Guides
  (bsc#1250747) 
- Improved the description of the ability to aggregate user roles in
  Administration Guide (bsc#1250525) 
- Added steps for troubleshooting registering cloned clients to 
  Administration Guide (bsc#1250427)
- Removed reference to hub peripheral registration using mgradm
- Added information about requesting access to PTFs (bsc#1213308)
- Added note for the upgrade with third-party SSL certificates to Installation and Upgrade Guide
- Improved the warning about partial backups in Administration Guide
  (bsc#1250551)
- Removed reference to hub peripheral registration using mgradm.
- Documented System Hardware as a new Report in Administration Guide
- Shared header enablement for documentation.suse.com
- Fixed command for proxy installation (bsc#1249807)
- Added clarification about containerized proxy (bsc#1248247)
- Updated hub certificates deployment documentation (bsc#1249462)
- Improved documentation about migration (bsc#1245240)
- Fixed the hostname rename page for containers in Troubleshooting
  section in Administration Guide (bsc#1229825)
- Documented to use the same CA password during migrating from 4.3
  in Installation and Upgrade Guide (bsc#1247296)
- Added note about onboarding CentOS 7 clients with repositories
  disabled in Client Configuration Guide (bsc#1248467)
- Added information about storing custom channel related GPG key
  permanently in Administration Guide (bsc#1240225)
- Documented building and deploying certificate on Image Build
  Host (bsc#1248447)
- Package salt-minion superseded with venv-salt-minion; salt-minion
  for bootstrapping SLE clients only (bsc#1247323)
- Replaced salt-minion with venv-salt-minion package in Image
  Management chapter in Administration Guide (bsc#1248448)
- Added information on using pre-installed images to migrate from 4.3
  to 5.1 (bsc#1247786)
- Added support data upload feature to Administration Guide
- Documented stopping the server before rebooting the host operating
  system for the migration from 5.0 to 5.1 in Installation and
  Upgrade Guide (bsc#1247705)
- Removed reference to smdba from reference Guide (bsc#1247213)
- Fixed procedure name for confidential computing in Administration
  Guide (bsc#1247318)
- Fixed invocation of spacewalk-repo-sync command in Client
  Configuration Guide (bsc#1246883)
- Fixed broken link in Administration Guide (bsc#1247322)
- Added instructions for third-party channels to Adminstration
  Guide (bsc#1246422)
- Fixed the package names for server and proxy air-gapped deployment
  (bsc#1247784)
- Documented how to write data to persistent volume in ISS chapter of
  Administration Guide (bsc#1246957)
- Fixed introduction of the Ansible chapter in Administration
  Guide (bsc#1244125)
- Fixed proxy migration from 5.0 to 5.1 in Installation and Upgrade
  Guide
- Added warning about old backup configuration in Administration Guide
  (bsc#1247481)
- Added SUSE Linux Enterprise Server command line registration in
  Installation and Upgrade Guide
- Fixed issues in Image Building chapter in the Administration Guide
  (bsc#1245987)
- Fixed upgrade procedure for server and proxy in Installation and
  Upgrade Guide (bsc#1247084)
- Added revision date to metadata for tracking document changes
- Removed duplicated paragraphs from Hub documentation in Large
  Deployments Guide
- Cleaned up Uyuni migration from legacy to container deployment in
  Installation and Upgrade Guide
- Added section about creation of database backup volume during
  migration or upgrade in Installation and Upgrade Guide
- Added deployment of Uyuni using images from RPM packages
- Fixed User Role Permissions table in Users chapter in
  Administration Guide (bsc#1246659)
- Confidential Computing command updated in Administration Guide
  (bsc#1246638)
- Fixed troubleshooting procedure about login timeout in Administration
  Guide
- Changed prerequisite for proxy conversion in Installation and Upgrade
  guide (bsc#1246158)
- Fixed persistent storage configuration details in Installation and Uprade
  Guide (bsc#1235567)
- Fixed the admonition in Client Configuration Guide (bsc#1233496)
- Added notes about how to run mgradm on security-enforced hosts
  (bsc#1243704)
- Reorganised files for better visibility of differences between AutoYaST
  and Kickstart profiles (bsc#1217755)
- Added detailed description of the scripts used for storage
  administration to Installation and Uprade Guide (bsc#1245241)
- Renamed parameter in Specialized Guides (bsc#1245241)
- Extended troubleshooting section with a reposync example (bsc#1211373)
- Added port 8022 for proxy in network requirements in Installation
  and Upgrade Guide
- Added admonition about supported clients as monitoring servers in
  Administration Guide
- Added hints to use swapfiles instead of swap partitions in
  Requirements section in Installation and Upgrade Guide
- Added examples for synchronizing BaseOS and AppStream channels for
  version 8 and 9 in Client Configuration Guide (bsc#1244822)
- Added Amazon Linux 2023 as supported client
- Fixed asciidoc menu macro issue with duplicate css class, menu
  items now display correctly
- Added documentation for task schedule errata-advisory-map-sync-default
  (bsc#1243808)
- Added note about AutoYaST profiles not having passwords
- Raised recommended proxy RAM value to 8 GB (bsc#1244552)
- Improved Hub documentation: peripheral list page, hierarchy of the Hub
  configuration page, and label for the Hub server FQDN
- Added missing DB SSL CA parameters in Administration Guide and
  added cross-reference from deployments in Installation and Upgrade
  Guide (bsc#1245120)
- Fixed rhn-search command execution in Backup and Restore chapter of
  the Administration Guide
- Added details about the behavior of the rescheduled failed action
  (bsc#1244065)
- Documented TFTP file synchronization after migrating a 4.3 proxy in
  Installation and Upgrade Guide (bsc#1244427)
- Added Role-Based Access Control (RBAC) chapter to Administration Guide
- Added reference to troubleshooting remote root login from Server migration
  from 5.0 on SUSE Linux Micro in Installation and Upgrade Guide
- Fixed Python script in Administration Guide (bsc#1244290)
- Added the recommendation for Swap memory in Installation and
  Upgrade Guide
- Fine tuned backup and restore procedures (bsc#1244524)
- Added missing Task Schedules to the list and fixed Task Schedule page after
  changing the page and allow only disabling Tasks, but not deleting them in
  Administration Guide
- Fixed procedure about converting client to proxy in Installation and
  Upgrade Guide
- Fixed procedure remediation procedure in Ansible chapter in
  Administration Guide (bsc#1244338)
- Fixed registry namespace and removed beta suffix from image names
  in Installation and Upgrade Guide
- Documented that Ansible for the control node must come from the distribution
  of the client (bsc#1244125)
- Linked API documentation from Reference Guide (bsc#1243243)
- Added information about passing environment variables to bootstrap
  script in Client Configuration Guide
- Documented root SSH login configuration with password in Troubleshooting
  section in Administration Guide (bsc#1243569)
- Moved Inter-Server Synchronization documentation from Administration
  to Large Deployments Guide
- Enhanced instructions about router advertisements and parameter
  value needed for IPv6 route in Installation and Upgrade Guide
  (bsc#1241034)
- Added missing 4505 and 4506 Salt ports in network requirements
  in Installation and Upgrade Guide
- Linked containers file to navigation list in Installation and
  Upgrade Guide
- Fixed broken links for the API FAQ and Scripts (bsc#1243243)
- Updated Hub Online Synchronization section with the latest
  UI changes in Large Deployment Guide
- Fixed KVM image version number in Installation and Upgrade Guide
  (bsc#1243416)
- Improved proxy deployment sections in Installation and Upgrade
  Guide
- Suggest to bootstrap a peripheral server before doing a Hub registration
- Fixed outdated urls pointing to API documentation in the Help section of the
  Reference Manual
- Added documentation for performing a distribution upgrade and migration of
  the Server and Proxy from version 5.0 to 5.1, supporting both SUSE Linux
  Enterprise SP6 to SP7 and SLE Micro 5.5 to SLE Micro 6.1
- Improved server migration in Installation and Upgrade Guide
- Updated Network Requirement section to add settings for server
  configuration behind HTTP OSI level 7 proxy
- Rebranding: changing extensions product during the registration from
  SUSE Manager to Multi-Linux-Manager for 5.1
- Added SUSE Linux Enterprise Server 15 SP7 as supported client
- Removed references to Inter-Server Synchronization version 1 from
  documentation
- Clarified that NFS with Cobbler is not supported (bsc#1240666)
- Removed SCAP file size limit from Reference Guide
- Added initial version of hub online synchronization to Large Deployments
  Guide in Specialized Guides
- Added conversion from onboarded client to a proxy to Installantion
  and Upgrade Guide
- Documented in Administration Guide that action chains are
  user-specific (bsc#1242561)
- Documented uptodate action in Common Workflows Guide as
  background information
- Added new backup/restore implementation
- Added new SSL certificate usage using podman secrets
- Added descriptions about various containers used
- Added the EULA for SUSE Multi-Linux Manager (bsc#1241647)
- Added background information about installing PTF on an air-gapped
  server in Installation and Upgrade Guide
- Fixed removing Salt bundle client procedure in Client Configuration
  Guide
- Documented renaming the journal folder when changing machine ID in
  Administration Guide (bsc#1241286)
- Added java.smtp_server parameter for mail configuration in
  Administration Guide (bsc#1241490)
- Added the copyright page for Uyuni
- Removed documentation for virtualization entitlements as they are not
  used anymore from Client Configuration Guide.
- Introduced dedicated Asciidoctor PDF themes for: Japanese, Korean
  and Simplified Chinese. Each theme now uses language-specific
  Noto Sans CJK fonts to handle subtle typographic differences and
  improve localization accuracy.
- Improved footer page numbering and chapter title formatting for all
  CJK languages.
- Updated CJK title pages to visually align with the English design.
- Resolved several long-standing formatting issues related to CJK output.
- Enabled future flexibility by allowing per-language refinements based
  on translator feedback.
- Unified hardware requirements for proxy and server installation
  in Installation and Upgrade Guide (bsc#1240635); images now
  default to 40 GB root partition
- Documented SUSE Linux Enterprise Server 15 as valid
  migration target (bsc#1240901)
- Restructured Server and Proxy Installation to better distinguish
  between SUSE Linux Enterprise Micro and SUSE Linux Enterprise
  Server as host operating system respectively (bsc#1239801)
- Added password definition requirements to Administration Guide
- Marked OVAL data consumption as Technology Preview
- Implemented PDF branding update for 2025 branding
- Enhanced CVE auditing feature in Administration Guide
- Added additional registry link to Installation and Upgrade Guide
  (bsc#1240010)
- Documented handling of pub directory of the web server in the
  context of proxy (bsc#1238827)
- Added instructions for Server and Proxy installation on SUSE Linux
  Enterprise Server 15 SP7 to Installation and Upgrade Guide
- Changed server host OS requirement for Uyuni to openSUSE Leap
  Micro 5.5
- Added system_listeventhistory to spacecmd reference in Reference
  Guide (bsc#1239604)
- Added new workflow for installing the product on ppc64le to Common
  Workflows book
- Implemented 2025 SUSE brand update for documentation.suse.com.
- Added links to supported features tables for third party operating
  systems (bsc#1236810)
- Removed Ubuntu 20.04 for SUSE Multi-Linux Manager from the list
  supported clients in Client Configuration Guide (bsc#1238481)
- Fixed procedure in Troubleshooting section about full disk event
  in the Administration Guide (bsc#1237535)
- Renamed client tools channel to new product name SUSE Multi-Linux
  Manager Client Tools
- Cleaned up backup and restore procedure in Administration Guide
  (bsc#1239630)
- Removed misleading admonition at the beginning of the Replace
  Certificates section in the Administration Guide
- Added note about cache_dir size in Installation and Upgrade
  Guide
- Added section about container image inspection to Image
  Management chapter in Administration Guide (bsc#1236323)
- Fixed typo in Installation and Upgrade Guide (bsc#1237403)
- Fixed host operating system name in Installation and Upgrade
  Guide
- Updated host renaming in Troubleshooting section of the
  Administration Guide
- Improved SSL certificate importing in Administration Guide
  (bsc#1236707)
- Activation key procedure enhanced in Client Configuration Guide
  (bsc#1233492)
- Remove image with beta reference in Installation and Upgrade Guide
  (bsc#1236678)
- Clarify functionality of CLM package/patch allow filters
  (bsc#1236234)
- Corrected the instruction for logging in to Azure instance in
  Specialized Guides (bsc#1234442)
- Updated Backup and Restore chapter regarding containerization in
  Administration Guide
- Corrected the wording in the procedure in Administration Guide
  (bsc#1236625)
- Improved documentation on CLM filters in Administration Guide
  (bsc#1234202)
- Corrected contact method in autoinstallation chapter in Client
  Configuration Guide
- Improved Remove Channel chapter in the Administration Gudie
  (bsc#1233500)
- Documented client tools details for Uyuni client registration in
  Client Configuration Guide
- Corrected server SSL self-signed certificates renewal procedure
  in Administration Guide (bsc#1235696)
- Updated external Link in Client Configuration Guide (bsc#1235825)
- Added admonition that NFS does not support SELinux labeling and should
  not be used in Installation and Upgrade Guide
- Updated product migration in Client Configuration Guide: added SUSE
  Linux Enterprise Server to SUSE Linux Enterprise Server for SAP
  Applications and extensions enabled automatically
- Deprecated Debian 11
- Deprecated the Quickstart Guide as it duplicated documentation
  from the Installation and Upgrade Guide
- Added retail MAC based terminal naming in Retail Guide (jsc#SUMA-314)
- Added support for SUSE Linux Micro 6.1
- Added example for LDAP integration with Active Directory in
  Administration Guide (bsc#1233696)
- Updated ports listing according to hidden ports file and fixed
  references in Installation and Upgrade Guide
- Added step to refresh repository before calling transactional-update
  in Installation and Upgrade Guide
- Updated Troubleshooting Autoinstallation in Administration Guide
- Added ports overview images in Installation and Upgrade Guide
  (bsc#1217338)
- Added external link for creating virtual network peer for Azure in
  Specialized Gudes (bsc#1234441)
- Documented how to replace existing certificates via mgrctl (bsc#1233793)
- Clarified SSH authentication methods during Web UI bootstrap process in
  Client Configuration Guide (bsc#1233497)
- Changes proxy helm installation to use package from OS channel in
  Installation and Upgrade Guide
- Documented onboarding SSH connected Ubuntu clients with install-created
  user in Client Configuration Guide (bsc#1213437)
- Added Saline documentation to Salt Guide
- Replaced mgradm with mrgctl in Installation and Upgrade Guide
- Corrected metadata signing section in Administration Guide
- Added Open Enterprise Server 24.4 and 23.4 as supported client systems
  (bsc#1230585)
- Improved SSL certificate handling in Administration Guide
- Make proper use of terminal inside the container in Retail Guide
  (bsc#1233871)
- Added new workflow with the instructions about RAW image usage
  to Common Workflows book
- Added reminder note to unregister before registration to Client
  Configuration Guide
- Fixed podman parameter name in Disconnected Setup chapter of the
  Administration Guide (bsc#1233383)
- Added details on image management in Administration Guide (bsc#1222574)
- Documented Cobbler option to enable boot ISOs with Secure Boot in
  Client Configuration Guide
- Fixed Uyuni repository link and removed netavark from the installation
  command
- Updated OpenSUSE Leap micro 5.5 download link
- Added documentation on deploying SUSE Manager Proxy in Public
  Cloud in Large Deployment Guide
- Added admonition about disabling data synchronization with SCC in
  Administration Guide
- Added note about SLE Micro entitlement being included in SUSE
  Manager extensions' entitlements (bsc#1230833)
- Added VMware image deployment documentation for Proxy in the
  Installation and Upgrade Guide (bsc#1227852)
- Added information on upgrading server and proxy containers also for
  Uyuni
- Added note about case sensitivity of organization name to
  Inter-Server Synchronization chapter of Administration Guide
- Added reminder note to de-register before registration to Client
  Configuration Guide (bsc#1216946)
- Added admonition about podman related IP forwarding configuration to
  Requirements in Installation and Upgrade Guide (bsc#1224318)
- Updated Hub chapter in Large Deployments Guide (bsc#1215815)
- Add registry.suse.com to the list of required URLs in the Network
  Requirements section of the Installation and Upgrade Guide
- Fixed SSH Push and SSH Push (with tunnel) contact method sections in
  Client Configuration Guide
- Added missing architecture to Installation and Upgrade Guide
  (bsc#1230670)
- Corrected command for containerized proxy in Installation and Upgrade
  Guide (bsc#1231398)
- List of required URLs extended in Installation and Upgrade Guide
  (bsc#1230741)
- Updated incorrect URL references for both the Server and Proxy in the
  Quickstart and Installation Guides
- Fixed hardcoded version entries for Uyuni in page content
- Removed 4.3 version entries in migration documentation
- The Quickstart Guide for Proxy contained legacy content. Updated
  to match containerized deployment
- Fixed incorrect hardcored product versions. 2024.04 -> 2024.08
- Added information for running mgr-ssl-cert-setup in Administration Guide
  (bsc#1229079)
- Added reference to Inter-Server Synchronization in Administration Guide
  (bsc#1230943)
- Documented consistently Leap Micro as Uyuni container host system in
  Installation and Upgrade Guide
- Documented that is LVM not needed in default cases in Installation
  and Upgrade Guide (bsc#1228319)
- Removed inconsistent information about persistent storage (bsc#1230502)
- Updated database backup and restore procedures using smdba in Administration
  Guide
- Documented krb5.conf configuration (bsc#1229077)
- Added VMware image deployment documentation for Server in the
  Installation and Upgrade Guide (bsc#1227852 and bsc#1228351)
- Documented migrating clients such as AlmaLinux, CentOS, Oracle Linux,
  and Rocky Linux to SUSE Liberty Linux and SUSE Liberty Linux 7 to
  SUSE Liberty Linux 7 LTSS
- Added documentation about orphaned packages in Client Configuration
  Guide (bsc#1227882)
- Clarified meaning of Default contact method in Client Configuration
  Guide
- Added prerequisite for server migration in Installation and Upgrade Guide
  (bsc#1229902)
- Updated information on PostgreSQL version in Installation and Upgrade
  Guide
- Documented Ubuntu 24.04 LTS as a supported client OS in Client
  Configuration Guide
- Updated outdated links in Retail Guide
- Added troubleshooting section about full disk with containers in
  Administration Guide and notes to persistent storage setup in Installation
  and Upgrade Guide
- Added volume SSSD to the list of etc persistent volumes to Installation and
  Upgrade Guide
- Documented using openSUSE Leap Micro as the host operating system for
  Uyuni Proxy
- Added uyuni-storage-setup-server package to server deployment and
  uyuni-storage-setup-proxy to proxy deployment in Installation and Upgrade
  Guide
- Updated legacy Uyuni Server to containerized Server migration in Installation
  and Upgrade Guide
- In network ports section, added port 443 for clients and removed
  Cobbler only used internally (bsc#1217338)
- Added installer-updates.suse.com to the list of URLs in Installation
  and Upgrade Guide (bsc#1229178)
- Improved documentation around non-compliant packages (also known as extra
  packages) in Reference Guide
- Restructured documentation of Systems menu and system details tab in
  Reference Guide
- Enhanced instructions about the permissions for the IAM role
  in Public Cloud Guide
- Updated legacy Uyuni Server to containerized Server migration in Installation
  and Upgrade Guide
- Removed Verify Packages section from Package Management chapter
  in Client Configuration Guide
- Documented activating AppStreams automatically with an
  activation key in Client Configuration Guide
- PAYG Docs updated for Azure and AWS
- Fixed button syntax typo in asciidoc content
- Added note on Salt minion timeout for Azure and PAYG (bsc#1226196)
- Added more links back to the Hardware Requirements section and enhance
  it to address questions about disk size recommendations
- Adjusted SUSE Manager Server registration in Installation and
  Upgrade Guide
- Fixed spacecmd commands in mgrctl calls in Installation and Upgrade
  Guide
- Change path for web.xml tuning in Administration Guide
- Adjusted SSL certificate renewal commands for containers in
  Administration Guide
- Updated SLE Micro update behavior in Installation and Upgrade Guide
- Updated Disconnected Server chapter in Administration Guide
  (bsc#1226728)
- Added note about usernames in PAM section in Administration Guide
 (bsc#1227599)
- Update Clients Update Using Recurring Actions workflow to account for
  uptodate state changes
- Fixed X logo position on mobile devices
- Removed raw image format from the available VM image deployment tables
  for both Server and Proxy on AArch64
- Fixed sequence of commands and preparation steps of the 4.3 to 5.0
  server migration procedure
- Consolidated terminology around the old server and the migration target
  in Installation and Upgrade Guide
- Added more information about the Prometheus alert manager in
  Administration Guide
- Add storage extra configuration for migration step in Installation and
  Upgrade Guide
- Added Salt Connectivity section to the Specialized Guides
- Improved Large Deployments Guide with better tuning values and
  extra parameters added
- Fix indentation on install storage instructions
- Update air-gap deployment for server and proxy
- Improved proxy migration and installation in Installation and Upgrade
  Guide
- Warn about copying GPG keys manually while migrating
- Warn about copying certification files manually while migrating
  4.3 servers to 5.0 in Installation and Upgrade Guide (bsc#1227198)
- Fixed proxy deployment details (bsc#1226843)
- Added admonition about domain name and IP address while migrating
  from a non-containerized server in Installation and Upgrade Guide
  (bsc#1227177)
- Fixed documentation concerning strict mode in Custom Channels chapter
  in the Administration Guide (bsc#1227130)
- Updated lists of SUSE Linux Enterprise hardening profiles in openSCAP
  chapter in the Administration Guide
- Added SUSE Liberty Linux 7 LTSS entries (bsc#1226913)
- Removed outdated disclaimer in CLM examples regarding AppStreams
  (bsc#1226687)
- Documented proper --mirrorPath parameter in disconnected setup chapter of
  the Administration Guide
- Fixed Activation Key link in SUSE Liberty Linux Clients page
- Fixed reposync path for SUSE Liberty Linux Base Media
- Fixed Adding Base Media to Custom Channels for SUSE Liberty Linux
  in Client Configuration guide
- Remove duplicate instructions from the Liberate Formula page
- Fixed Liberate Formula instructions
- Documented 'mgradm distribution' command to prepare installation
  source in Upgrade chapter of Client Configuration Guide
- Added VM image deployment documentation for Proxy and Server in the
  Installation and Upgrade Guide
- Removed legacy content from the Installation and Upgrade Guide
- Added SLE15 SP6 as supported client
- Added openSUSE Leap SP6 as supported client
- Adding SL Micro 6.0 as supported client
- Removed Apache exporter from monitoring chapter in the Administration
  Guide
- Updated autoinstallation usage with containerized server
  (bsc#1222692)
- Added image-sync boot image details (bsc#1206055)
- Updated retail workflow for SUSE Manager 5.0 containerized proxies
- Excluded detailed information about creating and running a CentOS
  errata checking script from SUSE Manager documentation in Client
  Configuration Guide
- Added note about CentOS 7 errata checking script applicable to
  non-containerized Uyuni installation in Client Configuration Guide
- Removed additional legacy content in the Installation and
  Upgrade guide
- Added Proxy migration documentation for SUSE Manager 5.0
- Documented availibility of package lock on RedHat-like clients
- Removed spacecmd functions that are not longer available
- Cleaned up Installation and Upgrade Guide navigation,
  additional legacy content removed
- Added information about mirroring Ubuntu ESM packages
- Started with referencing 5.0 API documentation
- Added deprecation warning for Inter-Server Synchronization (Version 1)
  feature in Administration Guide
- Added deprecation warning for virtualization management feature
  in Client Configuration Guide
- Added Proxy Quickstart Guide for deploying containerized Proxies
- Updated adding custom GPG key for repositories synchronization
- Added AppStream section to Client Configuration Guide
- Added Systems > Software > AppStreams documentation to Reference Guide
- Removed warning about limited AppStream support
- Added Confidential Computing as technology preview
  to Administration Guide
- Updated containerized server monitoring documentation
- Document channel management CLI tools in Reference Guide
- Use mgradm for Hub Server deployment in Large Deployment Guide
- Reogranized Installation and Upgrade navigation for clarity
- Improved document names and removed legacy content
- Updated default storage volume locations in documentation for
  containers
- Removed Unified Installer documentation from Requirements
- Removed Unified Installer documentation from General Requirements
- Updated ports documentation for containers
- Updated database migration sections in the Installation and Upgrade
  Guide
- Removed visualization feature
- Documented channel synchronization options in Administration Guide
- Added a new workflow describing how to update clients using recurring
  actions to Commown Workflows
- Improved navigation list font styles in the branding theme
- Cleaned up navlists for containers
- Fix self_update kernel option description (bsc#1221819)
- Deprecated client proxy script
- Added information about requirements for the PostgreSQL database
  in the Installation and Upgrade Guide (bsc#1220376)
- Fixed the instructions for SSL Certificates (bsc#1219061)
- Remove package sync paragraph in package-management doc since
  it is not available for Salt clients and traditional clients are no
  longer supported (bsc#1221279)
- Added reference from Hub documentation to Inter-Server
  Synchronization in Large Deployment Guide
- Bare-Metal System discovery feature disabled or dropped and thus, as
  it is part of the traditional stack, no longer documented
- Moved detailed description of client deletion from Common
  Workflows to Administration Guide
- Documented Virtualization Guest and Virtualization Host Formula
- Reformatted Supported Clients tables in Client Configuration Guide
  and Installation and Upgrade Guide
- Add documentation about SMTP timeout configuration
- Documented SSH key rotation in Salt Guide (bsc#1170848)
- Documented liberate formula in Salt Guide
- Fixed Prepare on-demand images section in Client Configuration Guide
  (bsc#1219130)
- Fixed a changed configuration parameter for salt-ssh
- Added container deployment documentation to the Installation and
  Upgrade Guide
- Fixed incorrect references to SUSE Linux Enterprise Server 15 SP4
  as base product for SUSE Manager
- Update the repository needed to install mgrpxy
- Added Pay-as-you-go on the Cloud: FAQ document to SUSE Manager
  documentation
- Updated max-connections tuning recommendation in Large Deployment Guide
- Added troubleshooting instructions for setting up in public cloud
  (BYOS) to Administration Guide
- Added detailed information about the messages produced by subscription
  matcher
- Added section about migrating Enterprise Linux (EL) clients to SUSE Liberty
  Linux to Client Configuration Guide
- Inserted sudo configuration into the Salt SSH section taken from
  traditional client documentation in the Client Configuration Guide
- Added Pay-as-you-go as supported service on Azure to the Public Cloud Guide
- Updated the proxy installation in Installation and Upgrade Guide to use
  the mgrpxy tool
- Added note about refreshing pillar data in Salt Guide (bsc#1189047)
- Added and fixed configuration details in Troubleshooting Renaming
  Server in Administration Guide
- Added openSUSE Leap to Supported Features navigation list in Client
  Configuration Guide (bsc#1218094)
- Described new monitoring metrics for Salt queue in Administration Guide
- Remove mentioning that CVE number for CVE auditing is optional (bsc#1218019)
- Fix xrefs for internal book references
- Corrected channel names for CentOS 7 Updates & Extras in CentOS Client
  Configuration Guide
- Documented bootstrap settings for SUSE Linux Enterprise Micro in
  Client Configuration Guide (bsc#1216394)
- Fixed RHEL channel names for bootstrapping in Client Configuration Guide
- Removed traditional client stack documentation such as command line
  tools in Reference Guide
- Corrected command mgr-push to mgrpush in Administration Guide (bsc#1215810)
- Added Pay-as-you-go for Azure documentation to the Specialized Guides
  book
- Removed traditional client stack documentation such as rhnsd in
  Troubleshooting Guide
- Updated Red Hat OVAL data URL and file in CentOS Client Configuration Guide
- Added Pay-as-you-go limitations chapter to Pay-as-you-go Guide
- ssh-push-default task renamed to ssh-service-default
- Removed Ubuntu 18.04 from the list of supported clients
- Fixed file location in Custom Salt Formulas section of Salt Guide
- Documented using Virtualization Host formula in Client Configuration Guide
- Document Amazon Linux 2023
- Added support for SUSE Linux Enterprise Micro 5.5 and openSUSE
  Leap Micro 5.5 clients to Installation and Upgrade Guide, and to
  Configuration Guide
- Added Liberty Linux versions 7 and 8 to the supported features matrix in
  the Client Configuration and in Installation and Upgrade Guide
- Updated Twitter handle reference in documentation UI
- Started with removing traditional client documentation in Client
  Configuration Guide and removed cross references to other Guides
- Fixed parser error with ifeval or url tag in Image management section
  of Administration Guide
- Replaced "Quick Start: Public Cloud" with "Public Cloud Guide" in
  Specialized Guides
- Added Debian 12 as supported client in Client Configuration Guide
- Added legend to table in Configuration Management section of Client
  Configuration Guide
- Fixed delete channel procedure in Channel management section in
  Administration Guide
- Corrected the client tools channel name in Client Configuration Guide
  for SUSE Linux Enterprise Micro
- Fixed links to HTML output of SUSE Linux Enterprise Server 15 SP4
  documentation
- Added note about using short hostname in the Quick Start: SAP
  (bsc#1212695)
- Documented migrating from traditional to Salt client in Client
  Configuration Guide
- Documented automatic hardware refresh with system-profile-refresh
  in the Reference Guide
- Mentioned the option to install Prometheus on Retail branch servers
  (bsc#1191143)
- Removed obsolete Retail migration description
- Added comment about SCC subscription to Administration Guide
  (bsc#1211270)
- Fixed link loop and clarified some server upgrade description details
  in the Installation and Upgrade Guide (bsc#1214471)
- Updated Hardware Requirements section about disk space for
  /var/spacewalk in Installation and Upgrade Guide
- Documented disabling automatic channel selection for cloned channels
  in Content Lifecycle Management chapter of Administration Guide
  (bsc#1211047)
- The configure-proxy.sh script no longer generates configuration channels
- Fixed broken links and references in the Image building file in
  Administration Guide
- Fixed navigation bar of Administration Guide
- Updated autoinstallation chapter in Client Configuration Guide about
  buildiso command in the context of Cobbler
- Removed end-of-life openSUSE Leap clients from the support matrix in
  the Client Configuration Guide
- Explained that version numbers in SP upgrade in common-workflows are
  just examples.
- Changed PostgreSQL documentation links to currently used version 15
- Added note about Jinja templating for configuration files management on
  Salt Clients in Client Configuration Guide
- Fixed DHCP example for Cobbler autoinstallation and added one per
  architecture in Client Configuration Guide (bsc#1214041)
- Added background information on Ansible playbooks in the Ansible chapter
  in Administration Guide (bsc#1213077)
- Added Best practices and Image pillars files to Retail Guide
- Added warning about channel synchronization failure because of invalidated
  credentials in Connect PAYG instance section of Installation and Upgrade
  Guide
- Added Saltboot redeployment subchapter in the Retail Guide
- Added note about SUSE Linux Enterprise Micro clients only having Node and
  Blackbox exporter for monitoring, in the Administration Guide available
  (bsc#1212246)
- Added detailed information about all supported SUSE Linux Enterprise Micro
  versions
- Updated Ansible chapter in Administration Guide for clarity (bsc#1213077)
- Removed step calling rhn-ssl-dbstore from the SSL setup that is now
  integrated into mgr-ssl-cert-setup in Administration Guide
- Listed supported key types for SSL certificates in Import SSL Certificates
  section of the Administation Guide.
- Added workflow describing channel removal to the Common Workflows Guide
- Fixed Ubuntu channel names in Ubuntu chapter of the Client
  Configuration Guide (bsc#1212827)
- Typo correction for Cobbler buildiso command in Client Configuration Guide
- Normalized information about client software providers in the Client
  Configuration Guide; Alibaba Cloud Linux, AlmaLinux, Amazon Linux,
  CentOS, Debian, Oracle, Rocky Linux, Ubuntu.
- Replaced plain text with dedicated attribute for AutoYaST
- File renamed to follow standardized format
- Changed filename for configuring Tomcat memory usage in Specialized Guides
  (bsc#1212814)
- Minimal memory requirement is 16 GB for SUSE Manager Server
  installation, also for test installation
- Added a note about Oracle Unbreakable Linux Network mirroring requirements
  in Client Configuration Guide (bsc#1212032)
- Added SUSE Linux Enterprise Server 15 SP5, SUSE Linux Enterprise Micro
  15.4, and openSUSE Leap Micro 15.4
- Fixed missing tables of content in the Reference Guide (bsc#1208577)
- Normalized Virtualization chapter in Client Configuration Guide
- Fixed instruction for SSO implementation example in the Administration
  Guide (bsc#1210103)
- Update Red Hat channel names to reflect the new custom channels for easier
  onboarding
- In the Installation and Upgrade Guide, unified SUSE Manager Proxy
  registration
- Warned about the impossibility of moving chained proxies in the
  Client Configuration Guide.
- Update the different OS support tables to the current technical support state
- Remove traditional client support documentation
- Recommend using Cobbler to build ISO images also for other systems but
  SUSE systems in the Autoinstallation chapter of the Client Configuration
  Guide
- Removed reference to non-exitent files in Reference Guide (bsc#1208528)
- Corrected the instructions for troubleshooting repository via proxy in
  the Administration Guide (bsc#1211276)
- Configured reboot method for SLE Micro clients and other transactional
  update systems in Client Configuration Guide
- Added note for clarification between self-installed and cloud instances
  of Ubuntu
- In the Database Migration chapter of the Installation and Upgrade
  Guide, we have added a note regarding the PostgreSQL user
- Added comment about activation keys for LTSS clients in Client
  Configuration Guide (bsc#1210011)
- Added server metrics list in Monitoring chapter of the Administration
  Guide
- Improved Pay-as-you-go documentation in the Install and Upgrade
  Guide (bsc#1208984)
- Updated API script examples to Python 3 in Administration Guide and
  Large Deployment Guide
- Added note about GPG key for Redhat custom channels in Client Configuration
  Guide
- Replace Expanded Support with SUSE Liberty Linux in navigation bar of
  Client Configuration Guide
- Added missing descriptions of taskomatic jobs in Administration Guide
- Salt version changed to 3006
- change default of salt_batch_size
- Change cleanup Salt Client description
- Add multiple gpg key url usage to Client Configuration Guide
- Adjusted SSO example in Administration Guide according to Keycloak 21.0.1
  update
- Documented custom info is available via pillars in Client Configuration
  Guide (bsc#1209253)
- Added updated options for rhn.conf file in the Administration Guide
  (bsc#1209508)
- Added instruction for Cobbler to use the correct label in Client Config Guide
  distro label (bsc#1205600)
- Adjusted python version and OpenSUSE Leap version in public cloud
  document (bsc#1209938)
- Fixed calculation of DB max-connections and align it with the supportconfig
  checking tool in the Tuning Guide
- Fixed Troubleshooting Corrupt Repositories procedure
- Branding updated for 2023
- New search engine optimization improvements for documentation
- Translations are now included in the webui help documentation
- Local search is now provided with the webui help documentation
- Rework Retail documentation to have generic configuration and examples
- Enhanced the note about the remove PTF capability in Administration Guide
- Added information about evaluation command parameter for OpenSCAP (bsc#1207931)
- Enhanced deleting clients in Client Configuration Guide
- Added instructions about contanerized proxy deployment to Installation and
  Upgrade Guide
- Explained how to use PTFs in SUSE Manager in the Administration Guide
- Warned about installing containerized proxy on traditional container host in
  Installation and Upgrade Guide
- Added openSUSE Leap 15.5 as a supported client
- Added SLE 15 SP5 as a supported client
- Removed z196 and z114 from listing in System Z chapter of the Installation
  and Upgrade Guide (bsc#1206973)
- Updated System Security with OpenSCAP chapter in Administration
  Guide replacing "standard" by "stig" profile
- Added description for using a custom container image in containerized proxy
- Added documentation about configuring external database during server setup
- Remove SLE Micro requirement to preinstall salt-transactional package
- Added information about java.salt_event_thread_pool_size in Large
  Deployments Guide
- Re-added statement about Cobbler support in Reference Guide and Client
  Configuration Guide (bsc#1206963)
- Fixed SLE Micro channel names in Client Configuration Guide
- Added SUSE Liberty Linux 9 clients as supported and use SUSE Liberty Linux
  name more consistently
- Added information about GPG key usuage in the Debian section of the Client
  Configuration Guide
- Add Grafana configuration instructions in Administration Guide.
- Clarified monitoring components support matrix in Client Configuration
  Guide
- Added information to use Hub when managing more than 10,000 clients
  to the Hardware Requirements in the Installation and Upgrade Guide
- Added Red Hat Enterprise Linux 9 clients as supported (bsc#1205896)
- Updated default number of changelog entries in Administration Guide
- Removed SLE Micro 5.1 notes
- Added SLE Micro bootstrapping note
- Improved Grafana configuration instructions in Administration Guide.
- Containerized proxy now allows usage of single FQDN.  Documented in
  Installation and Upgrade Guide.
- Fixed Rocky Linux documentation in Client Configuration Guide. Rocky Linux
  8 was partially removed by accident (bsc#1205470)
- Warning to emphasize about storage requirements before migration in
  Installation and Upgrade Guide
- Removed mentions to ABRT in Reference Guide
- Documented changed default behavior with handling local repositories
- Improved description of client-server contact methods
- Documented transactional update and reboot feature in Administration
  and Client Configuration Guide
- Added information about automatic custom channel synchronization
- Fixed incorrect order of steps when restarting database and
  spacewalk-service
- Added information  about OES repository enablement to Troubleshooting
  section in Administration Guide (bsc#1204195)
- Added note about shell quotation in Massmigration section of Client
  Configuration Guide.
- Documented the mgr-bootstrap command in Client Configuration Guide
- Fixed RES8 client tools label in Client Configuration Guide
- Added list of relevant collected server metrics in Monitoring chapter of
  Administration Guide
- In Troubleshooting section of the Administration Guide, update Register
  Cloned Clients procedure (bsc#1203971)
- Added information about changing Grafana administrator password (bsc#1203698)
- Moved all troubleshooting topics from Installation and Upgrade Guide
  and Client Configuration Guide to Administration Guide
- Warned about file ownership when restoring files in the Administration
  Guide (bsc#1202612)
- Fixed Ubuntu base channel name in Registering Ubuntu 20.04 and 22.04 Clients
  section of Client Configuration Guide
- Added Red Hat Enterprise Linux 9 clients as supported
- Added Almalinux 9, Oracle Linux 9, and Rocky Linux 9 as supported Client
  systems
- Only SUSE clients are supported as a monitoring server in Administration
  Guide.
- Fix description of default notification settings (bsc#1203422)
- Added missing Debian 11 references
- Removed references to Debian 9 as it approached EOL and support
- Document Helm deployment of the proxy on K3s and MetalLB in Installation
  and Upgrade Guide
- Added secure mail communication settings in Administration Guide
- Fix path to state and pillar files
- Documented how pxeboot works with Secure Boot enabled in Client
  Configuration Guide.
- Add repository via proxy issues troubleshooting page
- Added SLE Micro 5.2 and 5.3 as available as a technology preview in Client
  Configuration Guide, and the IBM Z architecture for 5.1, 5.2, and 5.3
- Improve instructions for setting up SSO with keycloak 9.0.2 in Administration
  Guide
- Mention CA certificate directory in the proxy setup description in the
  Installation and Upgrade Guide (bsc#1202805)
- Change import GPG key description
- Relax region requirement for payg connect feature -- not strictly required
- Documented mandatory channels in the Disconnected Setup chapter of the
  Administration Guide (bsc#1202464).
- Fixed the names of updates channels for Leap
- Fixed errors in OpenSCAP chapter of Administration Guide
- Documented how to onboard Ubuntu clients with the Salt bundle as a
  regular user
- Documented how to onboard Debian clients with the Salt bundle or plain Salt
  as a regular user
- Removed CentOS 8 from the list of supported client systems
- Extend the notes about using noexec option for /tmp and /var/tmp (bsc#1201210)
- Reverted single snippet change for two separate books
- Added Extend Salt Bundle functionality with Python packages using pip
- Salt Configuration Modules are no longer Technology Preview in Salt Guide.
- Removed Ubuntu 18.04 registration documentation

# Last packaged: 2023.10.19

- Described disabling local repositories in Client Configuration Guide
- Documented Ubuntu 22.04 LTS as a supported client OS in Client Configuration Guide
- Remove misleading installation screen shots in the Installation and Upgrade
  Guide (bsc#1201411)
- Fixed Ubuntu 18 Client registration in Client Configuration Guide (bsc#1201224)
- Removed sle-module-pythonX in VM Installation chapter of Installation and
  Upgrade Guide because SUSE Manager 4.3 does not require it
- In the Custom Channel section of the Administration Guide add a note
  about synchronizing repositories regularly.
- Removed SLE 11 from the list of supported client systems
- Update section about changing SSL certificates
- Added ports 1232 and 1233 in the Ports section of the Installation and
  Upgrade Guide; required for Salt SSH Push (bnc#1200532)
- Fixed 'fast' switch ('-f') of the database migration script in Installation and
  Upgrade Guide
- Added Uyuni Proxy requirements in Installation and Upgrade Guide.
- Updated Virtualization chapter in Client Configuration Guide; more on
  limitation other than Xen and KVM.
- Added information about registering RHEL clients on Azure in the Import
  Entitlements and Certificates section of the Client Configuration Guide
  (bsc#1198944).
- Replaced two identical tables in two separate books (Install/Upgrade Guide
  and Client Config Guide) with a single snippet
- In the Client Configuration Guide, package locking is supported for Ubuntu
  also on Uyuni
- Remove Uyuni Client tools from the list of the proxy channels in
  Installation and Upgrade Guide
- Updated openSUSE Leap version number to 15.4.
- Fixed VisibleIf documentation in Formula section of the Salt Guide
- Added note about importing CA certifcate in Installation and Upgrade Guide
  (bsc#1198358).
- Documented defining monitored targets using file-based service discovery
  provided in the Prometheus formula in the Salt Guide
- In Supported Clients and Features chapter in Client Configuration Guide,
  remove SLES 11 (bsc#1199147)
- Improve traditional client deprecation statement in Client Configuration
  Guide (bsc#1199714)
- Fixed spacewalk-remove-channel command in Delete Channels section of the
  Administration Guide (bsc#1199596)
- Add note about OpenSCAP security profile support in OpenSCAP section of
  the Administration Guide
- Large deployments guide includes mention to proxy (bsc#1199577)
- Enhanced Product Migration chapter in Client Configuration Guide with SLES
  example.
- In Common Workflows book, added new workflow for in-place upgrade of SLES
  with SUSE Manager
- In Administration Guide, Create Build Host section (docker), added warning
  about OS verstion requirement.
- In registration chapter of the Client Configuration Guide, add architecture
  note snippet to all the "Add software channel" sections.
- In Administration Guide, troubleshooting section, added content about high sync
  times between Server and Proxy over WAN connections
- In Administration Guide, documented the new behavior of spacewalk-report in
  combination with the reporting database.
- Documented org_createfirst in spacecmd chapter of the Reference Guide
- In Client Configuration Guide, adjust sequence of sections about registering
  RedHat Clients
- In Administration Guide, documented that monitoring tools are available in
  SUSE Linux Enterprise 12 and 15 and openSUSE Leap 15, but Grafana is not
  available on Proxy (bsc#1191143)
- Documented sle-module-python2 deactivation step in the minor version upgrade
  section of the Upgrade and Installation Guide (bsc#1197747).
- In the Large Deployments Guide, adapt tuning options for hub reporting according to latest
  performance tests
- Documented Autoyast installation features in Autoyast section of the Client
  Configuration Guide
- In Client Configuration Guide, clarified client upgrade issues.
- In the Large Deployments Guide, enhance section about hub reporting to add tuning options
  for the taskomatic jobs
- In Client Configuration Guide, added information about registration of
  version 12 of SUSE Linux Enterprise clients
- In Client Configuration Guide, mark the applying patches features as supported
  on Ubuntu
- SLE Micro in Client Configuration Guide: Update version number from
  5.0 to 5.1, and warn about Salt installation.
- In Administration Guide, renamed golang-github-wrouesnel-postgres_exporter to
  prometheus-postgres_exporter.
- In the Client Configuration Guide, used the correct procedure for registering
  Ubuntu 16.04 and 18.04 clients in Uyuni
- Clarified in Client Configuration Guide and Retail Guide that mandatory
  channels are automatically checked.  Also recommended channels as long as they
  are not deactivated (bsc#1173527).
- In Client Configuration Guide, fixed channel configuration and registration
  of Expanded Support clients.
- In Administration Guide, introduce a new tool to setup SSL certificates on Server
  and Proxy
- Added content about automatic client registration to Client Configuration
  Guide
- Clarified channel label name in Registering Clients with RHUI section of the
  Client Configuration Guide (bsc#1196067)
- Documented GPG encrypted Salt Pillars in the Specialized Guides, Salt book.
- Add warning to contact method for traditional clients regarding registering a
  deleted traditional client as Salt minion.
- Add note and information on client deletion page regarding registering a deleted
  traditional client as Salt minion.
- Add troubleshooting section regarding registering a deleted traditional client
  as Salt minion.
- In Throubleshooting Synchronization chapter in the Administration Guide
  added instructions for GPG removal.
- In Custom Channels chapter of the Administration Guide, provide information
  about creating metadata (bsc#1195294)
- In Client Configuration Guide, integrated SLE Micro Client documentation
  next to SUSE Linux Enterprise Client documentation and other related
  documentation improvements (bsc#1195145)
- Added a warning about the origin of the salt-minion package in the
  Register on the Command Line (Salt) section of the Client Configuration
  Guide
- In Custom Channels chapter of the Administration Guide, call
  spacewalk-repo-sync to import and trust GPG keys
- Removed wrong and superfluous sudo command in Backup and Restore of
  the Administration Guide.
- Add troubleshooting section about avoiding package conflicts with custom
  channels
- Added instructions for Pay-as-you-go to Installation and Upgrade Guide
- Merge translations of Installation and Upgrade Guide into the new
  combined book
- Removed end of life CaaSP references from documentation
- Introduce postgresql 14 with SUSE Manager 4.3
- Drop SUSE Manager 4.0 descriptions
- Documented moving Salt clients between proxies in Client Configuration
  Guide
- Added grub.cfg for GRUB 2 in the Upgrade chapter of the Client Configuration
  Guide (previously only menu.lst for GRUB Legacy was mentioned)
- In Troubleshooting section of the Client Configuration Guide, SUSE Linux
  Enterprise Server 11 clients also require previous SSL versions installed on
  the server
- In the Client Configuration Guide, explain how you find channel names to
  register older SUSE Linux Enterprise clients.
- In Retail Guide, adjust branch server version numbers (bsc#1193292)
- Merged Installation and Upgrade Guide to a single book
- Change configuration parameters to new static name in the Large Deployment Guide
- In the Client Configuration Guide, mark Yomi as unsupported on SLES 11 and 12
- In Specialized Guides, renamed page files to reflect the major topics they
  belong to.
- Created Specialized Guide as a container book for topics that are
  either not bespoke SUMA functionalities, or do not belong in any
  of the existing books
- Added Quick Start, containing one-page instructions for installing server
  or proxy, at the top of the navigation bar.
- In the Retail Guide, improve the auto-signed grains documentation
- Document Debian 11 as a supported OS as a client
- In Client Confguration Guide, for Debian and Ubuntu clients also provide
  the genuine architecture abbreviation "amd64".
- Documented repository URLs for Debian apt sources in the Custom Channel
  section of the Administration Guide
- In Client Configuration Guide add new section about registering with the
  Salt bundle
- In Client Confguration Guide fix the cent-errata.sh example script.
  RedHat now offers oval xml files in bzip2 format only.
- Fixed Uyuni for Retail Branch Server documention in the Retail Guide, and
  adjusted related SUSE Manager for Retail part accordingly.
- Fix command in Administration Guidelines, Backup and Restore chapter, and
  normalize layout.
- In the Client Configuration Guide, package locking is supported for Ubuntu and
  Debian.
- Fix base channel label for Red Hat 8 products in the Client Configuration Guide
- In the Client Configuration Guide, move the information about required
  Python to the section about the Web UI registration procedure.
- Warn about building ARM images on aarch64 architecture in the Administration
  Guide
- In the Installation Guide, fix slow downloads via proxy when huge
  files are requested (bsc#1185465)
- Added DNS resolution for minions incorrectly shown as down
  to the Troubleshooting section in the Client Configuration Guide
- Update 'max_connections' section of the Salt Guide
  (bsc#1191267)
- In the ports section of the Installation Guide, mention "tftpsync"
  explicitly for port 443 (bsc#1190665)
- In server upgrade procedure in the Upgrade Guide add 'zypper ref' step
  to refresh repositories reliably.
- Update 'effective_cache_size' section of the Salt Guide
  (bsc#1191274)
- Documented new filter in the Content Lifecycle Management chapter of
  the Administration Guide
- Added aarch64 support for selection of clients in the Installation
  Guide and Client Configuration Guide
- Documented AWS Permissions for Virtual Host Manager in VHM and
  Amazon Web Services chapter in the Client Configuration Guide
- Remove outdated patches note in the server update chapter of the
  Upgrade Guide
- Documented AWS Permissions for Virtual Host Manager in VHM and
  Amazon Web Services chapter in the Client Configuration Guide
- Documented Debian 12 as a supported client OS in Client Configuration Guide

# Last packaged: 2021-09-21 (Uyuni 2021.09)

- Version 2021.09
- Updated Proxy installation screenshots to reflect SUMA 4.2 version
  in Installation Guide
- Documented low on disc space warnings in the Managing Disk Space chapter in
  Administration Guide
- Removed Portus and CaaSP references from the image management chapter
  of the Administration Guide
- Fixed mgr-cfg-* issues in appendix of the Reference Guide.  Run the
  commands on the client (bsc#1190166).
- Documented package lock as a supported feature for some Salt clients
  in the Client Configuration Guide.
- Add information about pam service name limitations
- Replaced remaining occurrences of "Service Pack Migration" to
  "Product Migration".
- Reworded the Advanced virtual guest management description for
  clarity in Client Configuration Guide.
- Added a SLE Micro supported features section in Client Configuration
  Guide.
- logo url now supports new path to translation directory structure
- Added channel synchronization warning in the product migration chapter
  of the Client Configuration Guide.
- Added Rocky Linux 8 as a supported client in the Client Configuration Guide.
- Removed Red Hat Enterprise Linux 6, SUSE Linux Enterprise Server
  Expanded Support 6, Oracle Linux 6, CentOS 6, and Ubuntu 16.04 LTS
  as supported client systems in the Client Configuration Guide
  (bsc#1188656).
- Documented required SLES version for the Ansible control node in the
  Ansible Integration chapter of the Administration Guide (bsc#1189419)
- Added information about installing Python 3.6 on Centos, Oracle
  Linux, Almalinux, Rocky Linux, SUSE Linux Enterprise Server with
  Expanded Support, and Red Hat in the Client Configuration Guide
  (bsc#1187335).
- SUSE Manager: Universe is not required for installing spacecmd
  on Ubuntu (bsc#1187337)
- In the Prometheus chapter of the Administration Guide advise to store
  data locally (bsc#1188855).

# Last packaged: 2021-08-09 (Uyuni 2021.08)

- Additional information for ISS v2 about limitations and configuration
- Correct package name for PAM authentication (bsc#1171483)
- In the Ansible chapter of the Administration Guide mention that
  Ansible is available on proxy and retail branch server.
  Warn about Ansible hardware requirements in the Retail Guide.
- Warn better about over-writing images in public cloud in the Client
  Configuration Guide
- Client Configuration Guide: reorganized navigation bar to list SLES, openSUSE
  and other clients in alphabetical order for better user experience
- Reference Guide: removed underscores in page titles and nav bar links.
- Provide more information about Salt ssh user configuration in the Salt
  Guide (bsc#1187549).

- Documented Kiwi options and profile selection in Administration Guide.
- Added note about autoinstallation kernel options and Azure clients
- Added general information about SUSE Manager registration code that you
  can obtain from a "SUSE Manager Lifecycle Management+" subscription.
- Document new Salt SSH logs at the Client Configuration Guide, Troubleshooting
  section
- In the monitoring chapter of the Administration Guide mention that
  Prometheus is available on proxy and retail branch server.
  Warn about Prometheus hardware requirements in the Retail Guide (bsc#1186339).
- Documented spacecmd installation on Ubuntu 18.04 and 20.04 in Client
  Configuration Guide.
- Enhance Uyuni Proxy Upgrade chapter in the Upgrade guide.  Provide information
  about major and minor upgrade.
- Update the proxy migration procedure with the specifics for the migration
  from openSUSE Leap 15.2 to 15.3
- Documented version 2 of Inter-Server Synchronization in the Administration
  Guide
- Document Rocky Linux 8 as a client
- Added custom scrape configuration documentation to Salt guide
- Added documentation for inter server sync version 2
- Adding missing command for imported SSL certs
- Documented custom information in Salt pillars in the Client
  Configuration Guide.
- Document openSUSE Leap 15.3
- Updated Setup section in the Installation Guide about trouble
  shooting freely available products.
- Documented transfer between organizations in Reference and Administration
  Guide; this features was previously called "migrate".
- In Product Migration chapter of the Client Configuration Guide
  add a note to install pending updates before starting the migration
 (bsc#1187065).
- Fixed channel management command lines in Client Configuration Guide
- Documented upgrading PostfreSQL DB to version 13 in Upgrade Guide
- In the Supported Clients Table of the Client Configuration Guide, list
  Debian 10 and 9 unconditionally also in the context of SUSE Manager
  (bsc#1186427)
- Enable documenation of Amazon Linux as a supported client system in
  Client Configuration Guide (bsc#1186297)

# Last packaged: 2021-05-17

- Updated Image Management chapter in Administration Guide; python and python-xml
  are no longer required for container image inspection (bsc#1167586 and
  bsc#1164192")
- Add procedure to create cluster managed VM in Client Configuration Guide
- RHEL 6, Oracle Linux 6, CentOS 6, SUSE Linux Enterprise Expanded Support 6,
  and Ubuntu 16.04 are end-of-life upstream and no longer supported by SUSE as
  client operating systems.
- Documented upgrading to version 4.2 in Upgrade Guide (bsc#1185711).
- Fixed URL of API documentation

