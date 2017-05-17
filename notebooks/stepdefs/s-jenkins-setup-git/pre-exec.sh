ssh -qi ~/mykeypair root@${INSTANCE_IP} -p ${INSTANCE_PORT} <<EOF 2> /dev/null

# Installs jenkins cli tool to make calls through terminal
curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar

# Installs the plugins
java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin git git-client

# set up default settings

cat <<XML_FILE > "$filename"
<?xml version='1.0' encoding='UTF-8'?>
<hudson.plugins.git.GitSCM_-DescriptorImpl plugin="git@2.4.2">
  <generation>1</generation>
  <globalConfigName>gitUser</globalConfigName>
  <globalConfigEmail>your@email.jp</globalConfigEmail>
  <createAccountBasedOnEmail>false</createAccountBasedOnEmail>
</hudson.plugins.git.GitSCM_-DescriptorImpl>
XML_FILE

service jenkins restart

while ! curl -I -s http://localhost:8080/ | grep -q "200 OK" ; do
    echo "Waiting for Jenkins..."
    sleep 3
done

echo "Jenkins is ready."

EOF
