ssh -i ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} <<EOF 2> /dev/null
    [[ -d ~/templates ]] || mkdir ~/templates
    [[ -f ~/templates/config.xml ]] || cat <<XML_BASE > ~/templates/config.xml
<?xml version='1.0' encoding='UTF-8'?>
<project>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>false</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders/>
  <publishers/>
  <buildWrappers/>
</project>
XML_BASE
EOF
