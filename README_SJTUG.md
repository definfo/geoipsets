Get Started
---

```sh
# Clone the repo
git clone https://github.com/definfo/geoipsets --depth 1
cd geoipsets

# Install to /usr/local/bin/geoipsets
uv --directory=python/ run setup.py install
```

Usage
---

### iptables

```sh
mkdir -p /etc/iptables

# IPv4: Drop only connections to port 873 from CN.ipv4
iptables --insert INPUT -p tcp --dport 873 -m set --match-set CN.ipv4 src -j DROP
iptables --insert INPUT -p udp --dport 873 -m set --match-set CN.ipv4 src -j DROP
iptables-save > /etc/iptables/iptables.rules

# IPv6: Drop only connections to port 873 from CN.ipv6
ip6tables --insert INPUT -p tcp --dport 873 -m set --match-set CN.ipv6 src -j DROP
ip6tables --insert INPUT -p udp --dport 873 -m set --match-set CN.ipv6 src -j DROP
ip6tables-save > /etc/iptables/ip6tables.rules
```

### firewalld

```sh
# Load ipsets from generated XML files
firewall-cmd --permanent --new-ipset-from-file=/var/local/geoipsets/dbip/firewalld/CN.ipv4.xml
firewall-cmd --permanent --new-ipset-from-file=/var/local/geoipsets/dbip/firewalld/CN.ipv6.xml

# Create a rich rule to drop connections to port 873 from CN
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source ipset="CN.ipv4" port port="873" protocol="tcp" drop'
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source ipset="CN.ipv4" port port="873" protocol="udp" drop'
firewall-cmd --permanent --add-rich-rule='rule family="ipv6" source ipset="CN.ipv6" port port="873" protocol="tcp" drop'
firewall-cmd --permanent --add-rich-rule='rule family="ipv6" source ipset="CN.ipv6" port port="873" protocol="udp" drop'

# Reload firewalld to apply changes
firewall-cmd --reload
```

Updates
-----------

Data is updated regularly so it's preferable to execute a weekly task to retrieve the latest geo IP sets. Install and configure the *systemd* service and timer:

```sh
cp python/geoipsets.conf /etc/
cp -R systemd/update-geoipsets.* /etc/systemd/system/
chown root:root /etc/systemd/system/update-geoipsets.service /etc/systemd/system/update-geoipsets.timer
systemctl start update-geoipsets.timer && systemctl enable update-geoipsets.timer
```

Execute the service once manually to initially populate the set data.

```sh
systemctl start update-geoipsets.service
```

Set data is placed in **/var/local** by default. Use the `--output-dir` option to change this.

You may need to enable the relevant network *wait* service to avoid the script running on boot before a network connection is available. eg. if using *systemd-networkd* for network management:

```sh
systemctl start systemd-networkd-wait-online.service && systemctl enable systemd-networkd-wait-online.service
```

## Resume from previous state

### iptables

```sh
/usr/local/bin/geoipsets --config-file /etc/geoipsets.conf
ipset restore --file /var/local/geoipsets/dbip/ipset/ipv4/CN.ipv4
ipset restore --file /var/local/geoipsets/dbip/ipset/ipv6/CN.ipv6
ipset save --file /etc/ipset/ipset.conf
```

### firewalld

```sh
/usr/local/bin/geoipsets --config-file /etc/geoipsets.conf
firewall-cmd --permanent --new-ipset-from-file=/var/local/geoipsets/dbip/firewalld/CN.ipv4.xml
firewall-cmd --permanent --new-ipset-from-file=/var/local/geoipsets/dbip/firewalld/CN.ipv6.xml
firewall-cmd --reload
```
