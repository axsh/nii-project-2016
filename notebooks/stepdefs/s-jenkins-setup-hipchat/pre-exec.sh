ssh -qi ~/mykeypair root@10.0.2.100 <<EOF 2> /dev/null

# Installs jenkins cli tool to make calls through terminal
curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar

# Installs the plugins

java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin hipchat

# set up default settings

cat <<XML_FILE > "$filename"
<?xml version='1.0' encoding='UTF-8'?>
<jenkins.plugins.hipchat.HipChatNotifier_-DescriptorImpl plugin="hipchat@1.0.0">
  <server>api.hipchat.com</server>
  <token>token</token>
  <v2Enabled>false</v2Enabled>
  <room>room</room>
  <sendAs>Jenkins</sendAs>
</jenkins.plugins.hipchat.HipChatNotifier_-DescriptorImpl>
XML_FILE

service jenkins restart

while ! curl -I -s http://localhost:8080/ | grep -q "200 OK" ; do
    echo "Waiting for Jenkins..."
    sleep 3
done

echo "Jenkins is ready."

EOF
