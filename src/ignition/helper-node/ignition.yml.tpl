variant: fcos
version: 1.0.0
passwd:
  users:
    - name: maintuser
      uid: 1001
      groups:
        - sudo
      ssh_authorized_keys:
        - '${ssh_pubkey}'
    - name: haproxy
      uid: 9999
      system: true
      no_create_home: true
      shell: /usr/sbin/nologin
    - name: registry
      uid: 9998
      system: true
      no_create_home: true
      shell: /usr/sbin/nologin
storage:
  directories:
    - path: /etc/haproxy
      mode: 0755
      user:
        name: haproxy
      group:
        name: haproxy
    - path: /etc/registry
      mode: 0755
      user:
        name: registry
      group:
        name: registry
    - path: /var/lib/registry/data
      mode: 0755
      user:
        name: registry
      group:
        name: registry
    - path: /var/lib/registry/auth
      mode: 0755
      user:
        name: registry
      group:
        name: registry
    - path: /var/lib/registry/certs
      mode: 0755
      user:
        name: registry
      group:
        name: registry
  files:
    - path: /etc/hostname
      overwrite: true
      mode: 0644
      user:
        name: root
      group:
        name: root
      contents:
        inline: ${fqdn}
    - path: /etc/haproxy/haproxy.cfg
      mode: 0640
      user:
        name: haproxy
      group:
        name: haproxy
      contents:
        inline: |
          global
              log    127.0.0.1 local0 notice
              daemon

          defaults
              mode                      http
              default-server            init-addr last,libc,none
              log                       global
              option                    httplog
              option                    dontlognull
              option  http-server-close
              option  forwardfor        except 127.0.0.0/8
              option  redispatch
              timeout http-request      10s
              timeout queue             1m
              timeout connect           10s
              timeout client            1m
              timeout server            1m
              timeout http-keep-alive   10s
              timeout check             10s
              retries                   3

          resolvers dns
            nameserver dns1  ${haproxy_dns}
            resolve_retries  3
            timeout resolve  1s
            timeout retry    1s
            hold    other    30s
            hold    refused  30s
            hold    nx       30s
            hold    timeout  30s
            hold    valid    10s
            hold    obsolete 30s

          listen stats
              bind *:5555
              stats enable
              stats uri /haproxy?stats

          frontend openshift-api-server
              bind *:6443
              default_backend openshift-apiserver
              mode tcp
              option tcplog

          backend openshift-apiserver
              balance source
              mode tcp
              server bootstrap ${ocp_bootstrap_fqdn}:6443 check resolvers dns
              server master00  ${ocp_master_0_fqdn}:6443  check resolvers dns
              server master01  ${ocp_master_1_fqdn}:6443  check resolvers dns
              server master02  ${ocp_master_2_fqdn}:6443  check resolvers dns

          frontend machine-config-server
              bind *:22623
              default_backend machine-config-server
              mode tcp
              option tcplog

          backend machine-config-server
              balance source
              mode tcp
              server bootstrap ${ocp_bootstrap_fqdn}:22623 check resolvers dns
              server master00  ${ocp_master_0_fqdn}:22623  check resolvers dns
              server master01  ${ocp_master_1_fqdn}:22623  check resolvers dns
              server master02  ${ocp_master_2_fqdn}:22623  check resolvers dns

          frontend ingress-http
              bind *:80
              default_backend ingress-http
              mode tcp
              option tcplog

          backend ingress-http
              balance source
              mode tcp
              server infra00 ${ocp_master_0_fqdn}:80 check resolvers dns
              server infra01 ${ocp_master_1_fqdn}:80 check resolvers dns
              server infra02 ${ocp_master_2_fqdn}:80 check resolvers dns

          frontend ingress-https
              bind *:443
              default_backend ingress-https
              mode tcp
              option tcplog

          backend ingress-https
              balance source
              mode tcp
              server infra00 ${ocp_master_0_fqdn}:443 check resolvers dns
              server infra01 ${ocp_master_1_fqdn}:443 check resolvers dns
              server infra02 ${ocp_master_2_fqdn}:443 check resolvers dns
    - path: /etc/registry/configuration.env
      overwrite: true
      mode: 0644
      user:
        name: root
      group:
        name: root
      contents:
        inline: |
          REGISTRY_AUTH=htpasswd
          REGISTRY_AUTH_HTPASSWD_REALM=Registry credentials
          REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd
          REGISTRY_HTTP_TLS_CERTIFICATE=/certs/certificate.pem
          REGISTRY_HTTP_TLS_KEY=/certs/private.key
          REGISTRY_COMPATIBILITY_SCHEMA1_ENABLED=true
    - path: /var/lib/registry/auth/htpasswd
      overwrite: true
      mode: 0644
      user:
        name: root
      group:
        name: root
      contents:
        inline: ${registry_htpasswd}
    - path: /var/lib/registry/certs/certificate.pem
      overwrite: true
      mode: 0644
      user:
        name: root
      group:
        name: root
      contents:
        inline: |
          ${registry_tls_certificate}
    - path: /var/lib/registry/certs/private.key
      overwrite: true
      mode: 0644
      user:
        name: root
      group:
        name: root
      contents:
        inline: |
          ${registry_tls_private_key}
systemd:
  units:
    - name: haproxy.service
      enabled: true
      contents: |
        [Unit]
        Description=HAProxy
        Documentation=https://www.haproxy.org/
        After=network-online.target
        Wants=network-online.target

        [Service]
        Type=simple
        TimeoutStartSec=180
        StandardOutput=journal
        ExecStartPre=-/bin/podman pull docker.io/haproxy:${haproxy_version}
        ExecStart=/bin/podman run --name %n --rm \
            --publish 80:80 \
            --publish 443:443 \
            --publish 6443:6443 \
            --publish 5555:5555 \
            --publish 22623:22623 \
            --volume  /etc/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro,z \
            docker.io/haproxy:${haproxy_version}
        Restart=on-failure
        RestartSec=5
        ExecStop=/bin/podman stop %n
        ExecReload=/bin/podman restart %n

        [Install]
        WantedBy=multi-user.target
    - name: registry.service
      enabled: true
      contents: |
        [Unit]
        Description=Registry
        Documentation=https://hub.docker.com/_/registry
        After=network-online.target
        Wants=network-online.target

        [Service]
        Type=simple
        TimeoutStartSec=180
        StandardOutput=journal
        ExecStartPre=-/bin/podman pull docker.io/registry:${registry_version}
        ExecStart=/bin/podman run --name %n --rm \
            --publish  5000:5000 \
            --env-file /etc/registry/configuration.env \
            --volume   /var/lib/registry/data:/var/lib/registry:z \
            --volume   /var/lib/registry/auth:/auth:ro,z \
            --volume   /var/lib/registry/certs:/certs:ro,z \
            docker.io/registry:${registry_version}
        Restart=on-failure
        RestartSec=5
        ExecStop=/bin/podman stop %n
        ExecReload=/bin/podman restart %n

        [Install]
        WantedBy=multi-user.target
