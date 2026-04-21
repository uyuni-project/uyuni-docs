





<!DOCTYPE html>
<html class="gl-light ui-neutral with-header with-top-bar " lang="en">
<head prefix="og: http://ogp.me/ns#">
<meta charset="utf-8">
<meta content="IE=edge" http-equiv="X-UA-Compatible">
<meta content="width=device-width, initial-scale=1" name="viewport">
<title>tabs-block/behavior.js · main · Antora / Antora Asciidoctor Extensions · GitLab</title>
<script nonce="jz8CADdc+XSV0Ql9XFYIxQ==">
//<![CDATA[
window.gon={};gon.math_rendering_limits_enabled=true;gon.features={"explainCodeChat":false};gon.licensed_features={"fileLocks":true,"remoteDevelopment":true};
//]]>
</script>


<script nonce="jz8CADdc+XSV0Ql9XFYIxQ==">
//<![CDATA[
var gl = window.gl || {};
gl.startup_calls = null;
gl.startup_graphql_calls = [{"query":"query getBlobInfo(\n  $projectPath: ID!\n  $filePath: [String!]!\n  $ref: String!\n  $refType: RefType\n  $shouldFetchRawText: Boolean!\n) {\n  project(fullPath: $projectPath) {\n    __typename\n    id\n    repository {\n      __typename\n      empty\n      blobs(paths: $filePath, ref: $ref, refType: $refType) {\n        __typename\n        nodes {\n          __typename\n          id\n          webPath\n          name\n          size\n          rawSize\n          rawTextBlob @include(if: $shouldFetchRawText)\n          fileType\n          language\n          path\n          blamePath\n          editBlobPath\n          gitpodBlobUrl\n          ideEditPath\n          forkAndEditPath\n          ideForkAndEditPath\n          codeNavigationPath\n          projectBlobPathRoot\n          forkAndViewPath\n          environmentFormattedExternalUrl\n          environmentExternalUrlForRouteMap\n          canModifyBlob\n          canCurrentUserPushToBranch\n          archived\n          storedExternally\n          externalStorage\n          externalStorageUrl\n          rawPath\n          replacePath\n          pipelineEditorPath\n          simpleViewer {\n            fileType\n            tooLarge\n            type\n            renderError\n          }\n          richViewer {\n            fileType\n            tooLarge\n            type\n            renderError\n          }\n        }\n      }\n    }\n  }\n}\n","variables":{"projectPath":"antora/antora-asciidoctor-extensions","ref":"main","refType":"","filePath":"tabs-block/behavior.js","shouldFetchRawText":true}}];

if (gl.startup_calls && window.fetch) {
  Object.keys(gl.startup_calls).forEach(apiCall => {
   gl.startup_calls[apiCall] = {
      fetchCall: fetch(apiCall, {
        // Emulate XHR for Rails AJAX request checks
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        },
        // fetch won’t send cookies in older browsers, unless you set the credentials init option.
        // We set to `same-origin` which is default value in modern browsers.
        // See https://github.com/whatwg/fetch/pull/585 for more information.
        credentials: 'same-origin'
      })
    };
  });
}
if (gl.startup_graphql_calls && window.fetch) {
  const headers = {"X-CSRF-Token":"EkFmBapAcoJwwTtEk9gkeJaygeRpvHQrjcLO2Rl_k7YBizLg2EoZA4TpMgiI-4Qx7eGv3_HSWaac2efp6ZHRlQ","x-gitlab-feature-category":"source_code_management"};
  const url = `https://gitlab.com/api/graphql`

  const opts = {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...headers,
    }
  };

  gl.startup_graphql_calls = gl.startup_graphql_calls.map(call => ({
    ...call,
    fetchCall: fetch(url, {
      ...opts,
      credentials: 'same-origin',
      body: JSON.stringify(call)
    })
  }))
}


//]]>
</script>

<link rel="prefetch" href="/assets/webpack/monaco.8348edb5.chunk.js">

<link rel="stylesheet" href="/assets/application-22918e5e48d718e0977422d6c63347ce3199ac16206c958518b968c239529900.css" media="all" />
<link rel="stylesheet" href="/assets/page_bundles/tree-a237e29c78928e35b1336a49b7b8f58368c99e8d07d4108268e7015045ce9572.css" media="all" /><link rel="stylesheet" href="/assets/page_bundles/projects-96fb7ee62879b3c4fd19b2254784c0773ccb6312ae6d16a2f09cc06602ec2705.css" media="all" /><link rel="stylesheet" href="/assets/page_bundles/commit_description-5653213c51a6c90453a926cfc5e5e71ad9b41881a20a408bef8a303cf175435c.css" media="all" /><link rel="stylesheet" href="/assets/page_bundles/work_items-1a645abe79ac6548485568d8d034b67a35f8417ffba26e5da4b581e79dff7ba7.css" media="all" />
<link rel="stylesheet" href="/assets/application_utilities-c247da426ffe491fd417dd8796665950d863e26a62e51fa7f7cc94b8dbb109f5.css" media="all" />
<link rel="stylesheet" href="/assets/tailwind-47f87e61b7470d1de006dc1d8f0ef21a0dd2adf3569e485f9de0e33a5afdb7fd.css" media="all" />


<link rel="stylesheet" href="/assets/fonts-fae5d3f79948bd85f18b6513a025f863b19636e85b09a1492907eb4b1bb0557b.css" media="all" />
<link rel="stylesheet" href="/assets/highlight/themes/white-4e630d4cd339b5409eab2ddfb1ef5d66bb246024071ced5eba827c3d5c76ff62.css" media="all" />

<script src="/assets/webpack/runtime.e9f9a2f6.bundle.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/main.d8f8a69e.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/tracker.6bda30df.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/analytics.d8899000.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script nonce="jz8CADdc+XSV0Ql9XFYIxQ==">
//<![CDATA[
window.snowplowOptions = {"namespace":"gl","hostname":"snowplow.trx.gitlab.net","cookieDomain":".gitlab.com","appId":"gitlab","formTracking":true,"linkClickTracking":true}

gl = window.gl || {};
gl.snowplowStandardContext = {"schema":"iglu:com.gitlab/gitlab_standard/jsonschema/1-0-10","data":{"environment":"production","source":"gitlab-rails","plan":"opensource","extra":{},"user_id":null,"is_gitlab_team_member":null,"namespace_id":1984945,"project_id":8688107,"feature_enabled_by_namespace_ids":null,"context_generated_at":"2024-07-16T14:34:46.204Z"}}
gl.snowplowPseudonymizedPageUrl = "https://gitlab.com/namespace1984945/project8688107/-/blob/:repository_path";
gl.maskedDefaultReferrerUrl = null;
gl.ga4MeasurementId = 'G-ENFH3X7M5Y';


//]]>
</script>
<link rel="preload" href="/assets/application_utilities-c247da426ffe491fd417dd8796665950d863e26a62e51fa7f7cc94b8dbb109f5.css" as="style" type="text/css" nonce="4ETJtzmkftSP0i97XsQiKA==">
<link rel="preload" href="/assets/application-22918e5e48d718e0977422d6c63347ce3199ac16206c958518b968c239529900.css" as="style" type="text/css" nonce="4ETJtzmkftSP0i97XsQiKA==">
<link rel="preload" href="/assets/highlight/themes/white-4e630d4cd339b5409eab2ddfb1ef5d66bb246024071ced5eba827c3d5c76ff62.css" as="style" type="text/css" nonce="4ETJtzmkftSP0i97XsQiKA==">
<link crossorigin="" href="https://snowplow.trx.gitlab.net" rel="preconnect">
<link as="font" crossorigin="" href="/assets/gitlab-sans/GitLabSans-1e0a5107ea3bbd4be93e8ad2c503467e43166cd37e4293570b490e0812ede98b.woff2" rel="preload">
<link as="font" crossorigin="" href="/assets/gitlab-sans/GitLabSans-Italic-38eaf1a569a54ab28c58b92a4a8de3afb96b6ebc250cf372003a7b38151848cc.woff2" rel="preload">
<link as="font" crossorigin="" href="/assets/gitlab-mono/GitLabMono-08d2c5e8ff8fd3d2d6ec55bc7713380f8981c35f9d2df14e12b835464d6e8f23.woff2" rel="preload">
<link as="font" crossorigin="" href="/assets/gitlab-mono/GitLabMono-Italic-38e58d8df29485a20c550da1d0111e2c2169f6dcbcf894f2cd3afbdd97bcc588.woff2" rel="preload">
<link rel="preload" href="/assets/fonts-fae5d3f79948bd85f18b6513a025f863b19636e85b09a1492907eb4b1bb0557b.css" as="style" type="text/css" nonce="4ETJtzmkftSP0i97XsQiKA==">



<script src="/assets/webpack/sentry.30f8c5a0.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>


<script src="/assets/webpack/commons-pages.admin.abuse_reports.show-pages.dashboard.issues-pages.dashboard.milestones.show-pages.-6eb574d2.a7cf8c27.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/commons-pages.admin.abuse_reports.show-pages.dashboard.issues-pages.groups.boards-pages.groups.epic_-fa225b42.28d98c9d.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/commons-pages.admin.abuse_reports.show-pages.dashboard.issues-pages.groups.boards-pages.groups.epic_-67fb21ec.298d3f3c.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/commons-pages.groups.analytics.dashboards-pages.groups.analytics.dashboards.value_streams_dashboard--844b062c.958263f7.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/commons-pages.groups.new-pages.import.gitlab_projects.new-pages.import.manifest.new-pages.projects.n-a0973272.3b836268.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/commons-pages.search.show-super_sidebar.06a115ab.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/super_sidebar.a4f896a2.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/commons-pages.projects-pages.projects.activity-pages.projects.alert_management.details-pages.project-6c5bf499.0cde1033.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/commons-pages.admin.runners.show-pages.clusters.agents.dashboard-pages.dashboard.groups.index-pages.-5cdfa256.207262fa.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/117.0a041e9e.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/commons-pages.projects.blob.show-pages.projects.show-pages.projects.snippets.show-pages.projects.tre-c684fcf6.e21114a0.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/139.c99b3395.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/commons-pages.projects.blob.show-pages.projects.security.vulnerabilities.show-pages.projects.show-pa-5ff3b950.bc15ab41.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/commons-pages.projects.blob.show-pages.projects.show-pages.projects.tree.show.4a4e9dcf.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/commons-pages.projects.blob.show-pages.projects.commits.show-pages.projects.compare.show.8f83c28f.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<script src="/assets/webpack/pages.projects.blob.show.2c2ef4d3.chunk.js" defer="defer" nonce="jz8CADdc+XSV0Ql9XFYIxQ=="></script>
<meta content="object" property="og:type">
<meta content="GitLab" property="og:site_name">
<meta content="tabs-block/behavior.js · main · Antora / Antora Asciidoctor Extensions · GitLab" property="og:title">
<meta content="A lab of Asciidoctor extensions for use in sites built using Antora." property="og:description">
<meta content="https://gitlab.com/assets/twitter_card-570ddb06edf56a2312253c5872489847a0f385112ddbcd71ccfa1570febab5d2.jpg" property="og:image">
<meta content="64" property="og:image:width">
<meta content="64" property="og:image:height">
<meta content="https://gitlab.com/antora/antora-asciidoctor-extensions/-/blob/main/tabs-block/behavior.js" property="og:url">
<meta content="summary" property="twitter:card">
<meta content="tabs-block/behavior.js · main · Antora / Antora Asciidoctor Extensions · GitLab" property="twitter:title">
<meta content="A lab of Asciidoctor extensions for use in sites built using Antora." property="twitter:description">
<meta content="https://gitlab.com/assets/twitter_card-570ddb06edf56a2312253c5872489847a0f385112ddbcd71ccfa1570febab5d2.jpg" property="twitter:image">

<meta name="csrf-param" content="authenticity_token" />
<meta name="csrf-token" content="Q3_pw2VZ-jCxJ_GYOIcpEkkqc24Iie8IiukV_u3nSXJQtb0mF1ORsUUP-NQjpIlbMnldVZDnwoWb8jzOHQkLUQ" />
<meta name="csp-nonce" content="jz8CADdc+XSV0Ql9XFYIxQ==" />
<meta name="action-cable-url" content="/-/cable" />
<link href="/-/manifest.json" rel="manifest">
<link rel="icon" type="image/png" href="/assets/favicon-72a2cad5025aa931d6ea56c3201d1f18e68a8cd39788c7c80d5b2b82aa5143ef.png" id="favicon" data-original-href="/assets/favicon-72a2cad5025aa931d6ea56c3201d1f18e68a8cd39788c7c80d5b2b82aa5143ef.png" />
<link rel="apple-touch-icon" type="image/x-icon" href="/assets/apple-touch-icon-b049d4bc0dd9626f31db825d61880737befc7835982586d015bded10b4435460.png" />
<link href="/search/opensearch.xml" rel="search" title="Search GitLab" type="application/opensearchdescription+xml">




<meta content="A lab of Asciidoctor extensions for use in sites built using Antora." name="description">
<meta content="#ececef" name="theme-color">
</head>

<body class="tab-width-8 gl-browser-generic gl-platform-other " data-find-file="/antora/antora-asciidoctor-extensions/-/find_file/main" data-group="antora" data-group-full-path="antora" data-namespace-id="1984945" data-page="projects:blob:show" data-page-type-id="main/tabs-block/behavior.js" data-project="antora-asciidoctor-extensions" data-project-full-path="antora/antora-asciidoctor-extensions" data-project-id="8688107">

<script nonce="jz8CADdc+XSV0Ql9XFYIxQ==">
//<![CDATA[
gl = window.gl || {};
gl.client = {"isGeneric":true,"isOther":true};


//]]>
</script>


<header class="header-logged-out" data-testid="navbar">
<a class="gl-sr-only gl-accessibility" href="#content-body">Skip to content</a>
<div class="container-fluid">
<nav aria-label="Explore GitLab" class="header-logged-out-nav gl-display-flex gl-gap-3 gl-justify-content-space-between">
<div class="gl-display-flex gl-align-items-center gl-gap-1">
<span class="gl-sr-only">GitLab</span>
<a title="Homepage" id="logo" class="header-logged-out-logo has-tooltip" aria-label="Homepage" data-track-label="main_navigation" data-track-action="click_gitlab_logo_link" data-track-property="navigation_top" href="/"><svg aria-hidden="true" role="img" class="tanuki-logo" width="25" height="24" viewBox="0 0 25 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path class="tanuki-shape tanuki" d="m24.507 9.5-.034-.09L21.082.562a.896.896 0 0 0-1.694.091l-2.29 7.01H7.825L5.535.653a.898.898 0 0 0-1.694-.09L.451 9.411.416 9.5a6.297 6.297 0 0 0 2.09 7.278l.012.01.03.022 5.16 3.867 2.56 1.935 1.554 1.176a1.051 1.051 0 0 0 1.268 0l1.555-1.176 2.56-1.935 5.197-3.89.014-.01A6.297 6.297 0 0 0 24.507 9.5Z"
        fill="#E24329"/>
  <path class="tanuki-shape right-cheek" d="m24.507 9.5-.034-.09a11.44 11.44 0 0 0-4.56 2.051l-7.447 5.632 4.742 3.584 5.197-3.89.014-.01A6.297 6.297 0 0 0 24.507 9.5Z"
        fill="#FC6D26"/>
  <path class="tanuki-shape chin" d="m7.707 20.677 2.56 1.935 1.555 1.176a1.051 1.051 0 0 0 1.268 0l1.555-1.176 2.56-1.935-4.743-3.584-4.755 3.584Z"
        fill="#FCA326"/>
  <path class="tanuki-shape left-cheek" d="M5.01 11.461a11.43 11.43 0 0 0-4.56-2.05L.416 9.5a6.297 6.297 0 0 0 2.09 7.278l.012.01.03.022 5.16 3.867 4.745-3.584-7.444-5.632Z"
        fill="#FC6D26"/>
</svg>

</a></div>
<ul class="gl-list-none gl-p-0 gl-m-0 gl-display-flex gl-gap-3 gl-align-items-center gl-flex-grow-1">
<li class="header-logged-out-nav-item header-logged-out-dropdown md:gl-hidden">
<button class="header-logged-out-toggle" data-toggle="dropdown" type="button">
<span class="gl-sr-only">
Menu
</span>
<svg class="s16" data-testid="hamburger-icon"><use href="/assets/icons-ffa14d1d14478de17bd5c7220bf466194ad3bc99589858dae76a86bc89017324.svg#hamburger"></use></svg>
</button>
<div class="dropdown-menu">
<ul>
<li>
<a href="https://about.gitlab.com/why-gitlab">Why GitLab
</a></li>
<li>
<a href="https://about.gitlab.com/pricing">Pricing
</a></li>
<li>
<a href="https://about.gitlab.com/sales">Contact Sales
</a></li>
<li>
<a href="/explore">Explore</a>
</li>
</ul>
</div>
</li>
<li class="header-logged-out-nav-item gl-hidden md:gl-inline-block">
<a href="https://about.gitlab.com/why-gitlab">Why GitLab
</a></li>
<li class="header-logged-out-nav-item gl-hidden md:gl-inline-block">
<a href="https://about.gitlab.com/pricing">Pricing
</a></li>
<li class="header-logged-out-nav-item gl-hidden gl-inline-block">
<a href="https://about.gitlab.com/sales">Contact Sales
</a></li>
<li class="header-logged-out-nav-item gl-hidden md:gl-inline-block">
<a class="" href="/explore">Explore</a>
</li>
</ul>
<ul class="gl-list-none gl-p-0 gl-m-0 gl-display-flex gl-gap-3 gl-align-items-center gl-justify-content-end">
<li class="header-logged-out-nav-item">
<a href="/users/sign_in?redirect_to_referer=yes">Sign in</a>
</li>
<li class="header-logged-out-nav-item">
<a class="gl-button btn btn-md btn-confirm " href="/users/sign_up"><span class="gl-button-text">
Get free trial

</span>

</a></li>
</ul>
</nav>
</div>
</header>

<div class="layout-page page-with-super-sidebar">
<aside class="js-super-sidebar super-sidebar super-sidebar-loading" data-command-palette="{&quot;project_files_url&quot;:&quot;/antora/antora-asciidoctor-extensions/-/files/main?format=json&quot;,&quot;project_blob_url&quot;:&quot;/antora/antora-asciidoctor-extensions/-/blob/main&quot;}" data-force-desktop-expanded-sidebar="" data-root-path="/" data-sidebar="{&quot;is_logged_in&quot;:false,&quot;context_switcher_links&quot;:[{&quot;title&quot;:&quot;Explore&quot;,&quot;link&quot;:&quot;/explore&quot;,&quot;icon&quot;:&quot;compass&quot;}],&quot;current_menu_items&quot;:[{&quot;id&quot;:&quot;project_overview&quot;,&quot;title&quot;:&quot;Antora Asciidoctor Extensions&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:8688107,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:&quot;shortcuts-project&quot;,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;manage_menu&quot;,&quot;title&quot;:&quot;Manage&quot;,&quot;icon&quot;:&quot;users&quot;,&quot;avatar&quot;:null,&quot;avatar_shape&quot;:&quot;rect&quot;,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/activity&quot;,&quot;is_active&quot;:false,&quot;pill_count&quot;:null,&quot;items&quot;:[{&quot;id&quot;:&quot;activity&quot;,&quot;title&quot;:&quot;Activity&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/activity&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:&quot;shortcuts-project-activity&quot;,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;members&quot;,&quot;title&quot;:&quot;Members&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/project_members&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:null,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;labels&quot;,&quot;title&quot;:&quot;Labels&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/labels&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:null,&quot;is_active&quot;:false}],&quot;separated&quot;:false},{&quot;id&quot;:&quot;plan_menu&quot;,&quot;title&quot;:&quot;Plan&quot;,&quot;icon&quot;:&quot;planning&quot;,&quot;avatar&quot;:null,&quot;avatar_shape&quot;:&quot;rect&quot;,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/issues&quot;,&quot;is_active&quot;:false,&quot;pill_count&quot;:null,&quot;items&quot;:[{&quot;id&quot;:&quot;project_issue_list&quot;,&quot;title&quot;:&quot;Issues&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/issues&quot;,&quot;pill_count&quot;:&quot;0&quot;,&quot;link_classes&quot;:&quot;shortcuts-issues has-sub-items&quot;,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;boards&quot;,&quot;title&quot;:&quot;Issue boards&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/boards&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:&quot;shortcuts-issue-boards&quot;,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;milestones&quot;,&quot;title&quot;:&quot;Milestones&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/milestones&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:null,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;iterations&quot;,&quot;title&quot;:&quot;Iterations&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/cadences&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:null,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;requirements&quot;,&quot;title&quot;:&quot;Requirements&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/requirements_management/requirements&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:null,&quot;is_active&quot;:false}],&quot;separated&quot;:false},{&quot;id&quot;:&quot;code_menu&quot;,&quot;title&quot;:&quot;Code&quot;,&quot;icon&quot;:&quot;code&quot;,&quot;avatar&quot;:null,&quot;avatar_shape&quot;:&quot;rect&quot;,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/merge_requests&quot;,&quot;is_active&quot;:true,&quot;pill_count&quot;:null,&quot;items&quot;:[{&quot;id&quot;:&quot;project_merge_request_list&quot;,&quot;title&quot;:&quot;Merge requests&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/merge_requests&quot;,&quot;pill_count&quot;:&quot;0&quot;,&quot;link_classes&quot;:&quot;shortcuts-merge_requests&quot;,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;files&quot;,&quot;title&quot;:&quot;Repository&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/tree/main&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:&quot;shortcuts-tree&quot;,&quot;is_active&quot;:true},{&quot;id&quot;:&quot;branches&quot;,&quot;title&quot;:&quot;Branches&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/branches&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:null,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;commits&quot;,&quot;title&quot;:&quot;Commits&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/commits/main?ref_type=heads&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:&quot;shortcuts-commits&quot;,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;tags&quot;,&quot;title&quot;:&quot;Tags&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/tags&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:null,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;graphs&quot;,&quot;title&quot;:&quot;Repository graph&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/network/main?ref_type=heads&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:&quot;shortcuts-network&quot;,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;compare&quot;,&quot;title&quot;:&quot;Compare revisions&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/compare?from=main\u0026to=main&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:null,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;file_locks&quot;,&quot;title&quot;:&quot;Locked files&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/path_locks&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:null,&quot;is_active&quot;:false}],&quot;separated&quot;:false},{&quot;id&quot;:&quot;build_menu&quot;,&quot;title&quot;:&quot;Build&quot;,&quot;icon&quot;:&quot;rocket&quot;,&quot;avatar&quot;:null,&quot;avatar_shape&quot;:&quot;rect&quot;,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/pipelines&quot;,&quot;is_active&quot;:false,&quot;pill_count&quot;:null,&quot;items&quot;:[{&quot;id&quot;:&quot;pipelines&quot;,&quot;title&quot;:&quot;Pipelines&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/pipelines&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:&quot;shortcuts-pipelines&quot;,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;jobs&quot;,&quot;title&quot;:&quot;Jobs&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/jobs&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:&quot;shortcuts-builds&quot;,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;pipeline_schedules&quot;,&quot;title&quot;:&quot;Pipeline schedules&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/pipeline_schedules&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:&quot;shortcuts-builds&quot;,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;test_cases&quot;,&quot;title&quot;:&quot;Test cases&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/quality/test_cases&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:&quot;shortcuts-test-cases&quot;,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;artifacts&quot;,&quot;title&quot;:&quot;Artifacts&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/artifacts&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:&quot;shortcuts-builds&quot;,&quot;is_active&quot;:false}],&quot;separated&quot;:false},{&quot;id&quot;:&quot;deploy_menu&quot;,&quot;title&quot;:&quot;Deploy&quot;,&quot;icon&quot;:&quot;deployments&quot;,&quot;avatar&quot;:null,&quot;avatar_shape&quot;:&quot;rect&quot;,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/releases&quot;,&quot;is_active&quot;:false,&quot;pill_count&quot;:null,&quot;items&quot;:[{&quot;id&quot;:&quot;releases&quot;,&quot;title&quot;:&quot;Releases&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/releases&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:&quot;shortcuts-deployments-releases&quot;,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;model_registry&quot;,&quot;title&quot;:&quot;Model registry&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/ml/models&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:null,&quot;is_active&quot;:false}],&quot;separated&quot;:false},{&quot;id&quot;:&quot;operations_menu&quot;,&quot;title&quot;:&quot;Operate&quot;,&quot;icon&quot;:&quot;cloud-pod&quot;,&quot;avatar&quot;:null,&quot;avatar_shape&quot;:&quot;rect&quot;,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/environments&quot;,&quot;is_active&quot;:false,&quot;pill_count&quot;:null,&quot;items&quot;:[{&quot;id&quot;:&quot;environments&quot;,&quot;title&quot;:&quot;Environments&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/environments&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:&quot;shortcuts-environments&quot;,&quot;is_active&quot;:false}],&quot;separated&quot;:false},{&quot;id&quot;:&quot;monitor_menu&quot;,&quot;title&quot;:&quot;Monitor&quot;,&quot;icon&quot;:&quot;monitor&quot;,&quot;avatar&quot;:null,&quot;avatar_shape&quot;:&quot;rect&quot;,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/incidents&quot;,&quot;is_active&quot;:false,&quot;pill_count&quot;:null,&quot;items&quot;:[{&quot;id&quot;:&quot;incidents&quot;,&quot;title&quot;:&quot;Incidents&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/incidents&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:null,&quot;is_active&quot;:false}],&quot;separated&quot;:false},{&quot;id&quot;:&quot;analyze_menu&quot;,&quot;title&quot;:&quot;Analyze&quot;,&quot;icon&quot;:&quot;chart&quot;,&quot;avatar&quot;:null,&quot;avatar_shape&quot;:&quot;rect&quot;,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/value_stream_analytics&quot;,&quot;is_active&quot;:false,&quot;pill_count&quot;:null,&quot;items&quot;:[{&quot;id&quot;:&quot;cycle_analytics&quot;,&quot;title&quot;:&quot;Value stream analytics&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/value_stream_analytics&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:&quot;shortcuts-project-cycle-analytics&quot;,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;contributors&quot;,&quot;title&quot;:&quot;Contributor analytics&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/graphs/main?ref_type=heads&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:null,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;ci_cd_analytics&quot;,&quot;title&quot;:&quot;CI/CD analytics&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/pipelines/charts&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:null,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;repository_analytics&quot;,&quot;title&quot;:&quot;Repository analytics&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/graphs/main/charts&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:&quot;shortcuts-repository-charts&quot;,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;code_review&quot;,&quot;title&quot;:&quot;Code review analytics&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/analytics/code_reviews&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:null,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;issues&quot;,&quot;title&quot;:&quot;Issue analytics&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/analytics/issues_analytics&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:null,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;insights&quot;,&quot;title&quot;:&quot;Insights&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/insights/&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:&quot;shortcuts-project-insights&quot;,&quot;is_active&quot;:false},{&quot;id&quot;:&quot;model_experiments&quot;,&quot;title&quot;:&quot;Model experiments&quot;,&quot;icon&quot;:null,&quot;avatar&quot;:null,&quot;entity_id&quot;:null,&quot;link&quot;:&quot;/antora/antora-asciidoctor-extensions/-/ml/experiments&quot;,&quot;pill_count&quot;:null,&quot;link_classes&quot;:null,&quot;is_active&quot;:false}],&quot;separated&quot;:false}],&quot;current_context_header&quot;:&quot;Project&quot;,&quot;support_path&quot;:&quot;https://about.gitlab.com/get-help/&quot;,&quot;docs_path&quot;:&quot;/help/docs&quot;,&quot;display_whats_new&quot;:true,&quot;whats_new_most_recent_release_items_count&quot;:7,&quot;whats_new_version_digest&quot;:&quot;48f0954709a6c67a67281dc64a482f8793143a5f90b37653d5fe82bcbb697b5c&quot;,&quot;show_version_check&quot;:null,&quot;gitlab_version&quot;:{&quot;major&quot;:17,&quot;minor&quot;:2,&quot;patch&quot;:0,&quot;suffix_s&quot;:&quot;&quot;},&quot;gitlab_version_check&quot;:null,&quot;search&quot;:{&quot;search_path&quot;:&quot;/search&quot;,&quot;issues_path&quot;:&quot;/dashboard/issues&quot;,&quot;mr_path&quot;:&quot;/dashboard/merge_requests&quot;,&quot;autocomplete_path&quot;:&quot;/search/autocomplete&quot;,&quot;settings_path&quot;:&quot;/search/settings&quot;,&quot;search_context&quot;:{&quot;group&quot;:{&quot;id&quot;:1984945,&quot;name&quot;:&quot;Antora&quot;,&quot;full_name&quot;:&quot;Antora&quot;},&quot;group_metadata&quot;:{&quot;issues_path&quot;:&quot;/groups/antora/-/issues&quot;,&quot;mr_path&quot;:&quot;/groups/antora/-/merge_requests&quot;},&quot;project&quot;:{&quot;id&quot;:8688107,&quot;name&quot;:&quot;Antora Asciidoctor Extensions&quot;},&quot;project_metadata&quot;:{&quot;mr_path&quot;:&quot;/antora/antora-asciidoctor-extensions/-/merge_requests&quot;,&quot;issues_path&quot;:&quot;/antora/antora-asciidoctor-extensions/-/issues&quot;},&quot;code_search&quot;:true,&quot;ref&quot;:&quot;main&quot;,&quot;scope&quot;:null,&quot;for_snippets&quot;:null}},&quot;panel_type&quot;:&quot;project&quot;,&quot;shortcut_links&quot;:[{&quot;title&quot;:&quot;Snippets&quot;,&quot;href&quot;:&quot;/explore/snippets&quot;,&quot;css_class&quot;:&quot;dashboard-shortcuts-snippets&quot;},{&quot;title&quot;:&quot;Groups&quot;,&quot;href&quot;:&quot;/explore/groups&quot;,&quot;css_class&quot;:&quot;dashboard-shortcuts-groups&quot;},{&quot;title&quot;:&quot;Projects&quot;,&quot;href&quot;:&quot;/explore/projects/starred&quot;,&quot;css_class&quot;:&quot;dashboard-shortcuts-projects&quot;}]}"></aside>

<div class="content-wrapper">

<div class="alert-wrapper gl-force-block-formatting-context">
































<div class="top-bar-fixed container-fluid" data-testid="top-bar">
<div class="top-bar-container gl-display-flex gl-align-items-center gl-gap-2">
<button class="gl-button btn btn-icon btn-md btn-default btn-default-tertiary js-super-sidebar-toggle-expand super-sidebar-toggle -gl-ml-3" aria-controls="super-sidebar" aria-expanded="false" aria-label="Primary navigation sidebar" type="button"><svg class="s16 gl-icon gl-button-icon " data-testid="sidebar-icon"><use href="/assets/icons-ffa14d1d14478de17bd5c7220bf466194ad3bc99589858dae76a86bc89017324.svg#sidebar"></use></svg>

</button>
<script type="application/ld+json">
{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[{"@type":"ListItem","position":1,"name":"Antora","item":"https://gitlab.com/antora"},{"@type":"ListItem","position":2,"name":"Antora Asciidoctor Extensions","item":"https://gitlab.com/antora/antora-asciidoctor-extensions"},{"@type":"ListItem","position":3,"name":"Repository","item":"https://gitlab.com/antora/antora-asciidoctor-extensions/-/blob/main/tabs-block/behavior.js"}]}


</script>
<div data-testid="breadcrumb-links" id="js-vue-page-breadcrumbs-wrapper">
<div data-breadcrumbs-json="[{&quot;text&quot;:&quot;Antora&quot;,&quot;href&quot;:&quot;/antora&quot;,&quot;avatarPath&quot;:&quot;/uploads/-/system/group/avatar/1984945/antora-gitlab.png&quot;},{&quot;text&quot;:&quot;Antora Asciidoctor Extensions&quot;,&quot;href&quot;:&quot;/antora/antora-asciidoctor-extensions&quot;,&quot;avatarPath&quot;:null},{&quot;text&quot;:&quot;Repository&quot;,&quot;href&quot;:&quot;/antora/antora-asciidoctor-extensions/-/blob/main/tabs-block/behavior.js&quot;,&quot;avatarPath&quot;:null}]" id="js-vue-page-breadcrumbs"></div>
<div id="js-injected-page-breadcrumbs"></div>
</div>


<div id="js-work-item-feedback"></div>


</div>
</div>

</div>
<div class="container-fluid container-limited project-highlight-puc">
<main class="content" id="content-body" itemscope itemtype="http://schema.org/SoftwareSourceCode">
<div class="flash-container flash-container-page sticky" data-testid="flash-container">
<div id="js-global-alerts"></div>
</div>






<div class="js-signature-container" data-signatures-path="/antora/antora-asciidoctor-extensions/-/commits/083fff26530f690c7970a4e6bc804885f60ca0e4/signatures?limit=1"></div>

<div class="tree-holder gl-pt-4" id="tree-holder">
<div class="nav-block">
<div class="tree-ref-container">
<div class="tree-ref-holder gl-max-w-26">
<div data-project-id="8688107" data-project-root-path="/antora/antora-asciidoctor-extensions" data-ref="main" data-ref-type="" id="js-tree-ref-switcher"></div>
</div>
<ul class="breadcrumb repo-breadcrumb">
<li class="breadcrumb-item">
<a href="/antora/antora-asciidoctor-extensions/-/tree/main">antora-asciidoctor-extensions
</a></li>
<li class="breadcrumb-item">
<a href="/antora/antora-asciidoctor-extensions/-/tree/main/tabs-block">tabs-block</a>
</li>
<li class="breadcrumb-item">
<a href="/antora/antora-asciidoctor-extensions/-/blob/main/tabs-block/behavior.js"><strong>behavior.js</strong>
</a></li>
</ul>
</div>
<div class="tree-controls gl-display-flex gl-flex-wrap gl-sm-flex-nowrap gl-align-items-baseline gl-gap-3">
<button class="gl-button btn btn-md btn-default has-tooltip shortcuts-find-file" title="Go to file, press &lt;kbd class=&#39;flat ml-1&#39; aria-hidden=true&gt;/~&lt;/kbd&gt; or &lt;kbd class=&#39;flat ml-1&#39; aria-hidden=true&gt;t&lt;/kbd&gt;" aria-keyshortcuts="/+~ t" data-html="true" data-event-tracking="click_find_file_button_on_repository_pages" type="button"><span class="gl-button-text">
Find file

</span>

</button>
<a data-event-tracking="click_blame_control_on_blob_page" class="gl-button btn btn-md btn-default js-blob-blame-link" href="/antora/antora-asciidoctor-extensions/-/blame/main/tabs-block/behavior.js"><span class="gl-button-text">
Blame
</span>

</a>
<a data-event-tracking="click_history_control_on_blob_page" class="gl-button btn btn-md btn-default " href="/antora/antora-asciidoctor-extensions/-/commits/main/tabs-block/behavior.js"><span class="gl-button-text">
History
</span>

</a>
<a aria-keyshortcuts="y" class="gl-button btn btn-md btn-default has-tooltip js-data-file-blob-permalink-url" data-html="true" title="Go to permalink &lt;kbd class=&#39;flat ml-1&#39; aria-hidden=true&gt;y&lt;/kbd&gt;" href="/antora/antora-asciidoctor-extensions/-/blob/42efa23797b7ef1c6bcc8866261df6a703117c01/tabs-block/behavior.js"><span class="gl-button-text">
Permalink
</span>

</a>
</div>
</div>

<div class="info-well gl-hidden sm:gl-block">
<div class="well-segment">
<ul class="blob-commit-info">
<li class="commit flex-row js-toggle-container" id="commit-083fff26">
<div class="avatar-cell gl-hidden sm:gl-block">
<a href="/mojavelinux"><img alt="Dan Allen&#39;s avatar" src="https://secure.gravatar.com/avatar/41a68e04243d81bd9499b655ef7d9e877bc31c7fe396ba84b6aa2141bf1c1092?s=160&amp;d=identicon" class="avatar s40 gl-hidden sm:gl-inline-block" title="Dan Allen"></a>
</div>
<div class="commit-detail flex-list gl-display-flex gl-justify-content-space-between gl-align-items-center gl-flex-grow-1 gl-min-w-0">
<div class="commit-content" data-testid="commit-content">
<a class="commit-row-message item-title js-onboarding-commit-item " href="/antora/antora-asciidoctor-extensions/-/commit/083fff26530f690c7970a4e6bc804885f60ca0e4">add tabs block extension</a>
<span class="commit-row-message d-inline d-sm-none">
&middot;
083fff26
</span>
<div class="committer">
<a class="commit-author-link js-user-link" data-user-id="11827" href="/mojavelinux">Dan Allen</a> authored <time class="js-timeago" title="Oct 3, 2018 8:16pm" datetime="2018-10-03T20:16:18Z" data-toggle="tooltip" data-placement="bottom" data-container="body">Oct 03, 2018</time>
</div>

</div>
<div class="commit-actions flex-row">

<div class="js-commit-pipeline-status" data-endpoint="/antora/antora-asciidoctor-extensions/-/commit/083fff26530f690c7970a4e6bc804885f60ca0e4/pipelines?ref=main"></div>
<div class="commit-sha-group btn-group gl-hidden sm:gl-flex">
<div class="label label-monospace monospace">
083fff26
</div>
<button class="gl-button btn btn-icon btn-md btn-default " title="Copy commit SHA" aria-label="Copy commit SHA" aria-live="polite" data-toggle="tooltip" data-placement="bottom" data-container="body" data-html="true" data-category="primary" data-size="medium" data-clipboard-text="083fff26530f690c7970a4e6bc804885f60ca0e4" type="button"><svg class="s16 gl-icon gl-button-icon " data-testid="copy-to-clipboard-icon"><use href="/assets/icons-ffa14d1d14478de17bd5c7220bf466194ad3bc99589858dae76a86bc89017324.svg#copy-to-clipboard"></use></svg>

</button>

</div>
</div>
</div>
</li>

</ul>
</div>
<div data-blob-path="tabs-block/behavior.js" data-branch="main" data-branch-rules-path="/antora/antora-asciidoctor-extensions/-/settings/repository#js-branch-rules" data-project-path="antora/antora-asciidoctor-extensions" id="js-code-owners"></div>

</div>
<div class="blob-content-holder js-per-page" data-blame-per-page="1000" id="blob-content-holder">
<div data-blob-path="tabs-block/behavior.js" data-can-download-code="true" data-explain-code-available="false" data-new-workspace-path="/-/remote_development/workspaces/new" data-original-branch="main" data-project-path="antora/antora-asciidoctor-extensions" data-ref-type="" data-resource-id="gid://gitlab/Project/8688107" data-target-branch="main" data-user-id="" id="js-view-blob-app">
<div class="gl-spinner-container" role="status"><span aria-label="Loading" class="gl-spinner gl-spinner-md gl-spinner-dark gl-vertical-align-text-bottom!"></span></div>
</div>
</div>

</div>
<script nonce="jz8CADdc+XSV0Ql9XFYIxQ==">
//<![CDATA[
  window.gl = window.gl || {};
  window.gl.webIDEPath = '/-/ide/project/antora/antora-asciidoctor-extensions/edit/main/-/tabs-block/behavior.js'


//]]>
</script>
<div data-ambiguous="false" data-ref="main" id="js-ambiguous-ref-modal"></div>

</main>
</div>


</div>
</div>


<script nonce="jz8CADdc+XSV0Ql9XFYIxQ==">
//<![CDATA[
if ('loading' in HTMLImageElement.prototype) {
  document.querySelectorAll('img.lazy').forEach(img => {
    img.loading = 'lazy';
    let imgUrl = img.dataset.src;
    // Only adding width + height for avatars for now
    if (imgUrl.indexOf('/avatar/') > -1 && imgUrl.indexOf('?') === -1) {
      const targetWidth = img.getAttribute('width') || img.width;
      imgUrl += `?width=${targetWidth}`;
    }
    img.src = imgUrl;
    img.removeAttribute('data-src');
    img.classList.remove('lazy');
    img.classList.add('js-lazy-loaded');
    img.dataset.testid = 'js-lazy-loaded-content';
  });
}

//]]>
</script>
<script nonce="jz8CADdc+XSV0Ql9XFYIxQ==">
//<![CDATA[
gl = window.gl || {};
gl.experiments = {};


//]]>
</script>

</body>
</html>

