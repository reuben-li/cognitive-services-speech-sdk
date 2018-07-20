#!/usr/bin/perl -i -p
#
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT license.
#
# vim:set expandtab shiftwidth=2 tabstop=2:
#
# (can be launched, for example, from a Git Bash prompt)
BEGIN {
  use File::Find;

  # Some REs
  $reNugetId = qr/\QMicrosoft.CognitiveServices.Speech\E/;
  $reMavenGroupId = qr/\Qcom.microsoft.cognitiveservices.speech\E/;
  $reMavenArtifactId = qr/\Qclient-sdk\E/;
  $reMavenId = qr/$reMavenGroupId:$reMavenArtifactId/;
  $rePkgConfig = qr/packages\.config/;
  $reCsProj = qr/.*\.csproj/;
  $reVcxProj = qr/.*\.vcxproj/;
  $reGradleBuild = qr/build\.gradle/;
  $reMavenPom = qr/pom\.xml/;

  $version = shift
    or die "Supply version to use as first argument\n";
  $samplesDir = shift
    or die "Supply directory to use as second argument\n";

  -d $samplesDir
    or die "Cannot find $samplesDir\n";

  @ARGV = ();
  find(sub {
    m(^(?:$rePkgConfig|$reCsProj|$reVcxProj|$reGradleBuild|$reMavenPom)$) &&
    push @ARGV, $File::Find::name
  }, $samplesDir);

  $seenPackageReference = 0;
  $mavenDepState = 0;
}
if ($ARGV ne $oldargv) {
  warn "Patching $ARGV\n";
  $oldargv = $ARGV;
}
$ARGV =~ m(.*/$rePkgConfig$) && s/(<package id="$reNugetId" version=")([^"]*)"/$1$version"/;
$ARGV =~ m(.*/(?:$reCsProj|$reVcxProj)$) && do {
  # <HintPath>...<HintPath>, <Import Project ... />, <Error ... />
  s((["'>](?:\.\.\\)*packages\\$reNugetId\.)[^\\]*\\)($1$version\\)g;

  # <PackageReference Include="Microsoft.CognitiveServices.Speech" Version="X" />
  s((?<=<PackageReference Include="$reNugetId" Version=")[^"]*)($version)g;

  # <PackageReference Include="Microsoft.CognitiveServices.Speech">\n<Version>X</Version>
  s((?<=<Version>)[^<]*)($version)g if $seenPackageReference;
  $seenPackageReference = m(<PackageReference Include="$reNugetId">);
};
$ARGV =~ m(.*/$reGradleBuild$) && s/(\bimplementation\s+(['"])$reMavenId:)(.*?)\2/$1$version$2/;
$ARGV =~ m(.*/$reMavenPom$) && do {
  if ($mavenDepState == 2) {
    $mavenDepState = 0 if s((?<=<version>)[^<]*)($version);
  } elsif ($mavenDepState == 1) {
    $mavenDepState = 2 if m(<artifactId>$reMavenArtifactId</artifactId>);
  } else {
    $mavenDepState = 1 if m(<groupId>$reMavenGroupId</groupId>);
  }
}
