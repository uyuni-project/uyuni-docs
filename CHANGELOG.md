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

