{
  "ignition": {
    "config": {
      "replace": {
        "source": null,
        "verification": {}
      }
    },
    "security": {
      "tls": {}
    },
    "timeouts": {},
    "version": "3.0.0"
  },
  "passwd": {
    "users": [
      {
        "groups": [
          "sudo"
        ],
        "name": "maintuser",
        "sshAuthorizedKeys": [
          "${ssh_pubkey}"
        ],
        "uid": 1001
      },
      {
        "name": "haproxy",
        "noCreateHome": true,
        "shell": "/usr/sbin/nologin",
        "system": true,
        "uid": 9999
      },
      {
        "name": "registry",
        "noCreateHome": true,
        "shell": "/usr/sbin/nologin",
        "system": true,
        "uid": 9998
      }
    ]
  },
  "storage": {
    "directories": [
      {
        "group": {
          "name": "haproxy"
        },
        "path": "/etc/haproxy",
        "user": {
          "name": "haproxy"
        },
        "mode": 493
      },
      {
        "group": {
          "name": "registry"
        },
        "path": "/etc/registry",
        "user": {
          "name": "registry"
        },
        "mode": 493
      },
      {
        "group": {
          "name": "registry"
        },
        "path": "/var/lib/registry/data",
        "user": {
          "name": "registry"
        },
        "mode": 493
      },
      {
        "group": {
          "name": "registry"
        },
        "path": "/var/lib/registry/auth",
        "user": {
          "name": "registry"
        },
        "mode": 493
      },
      {
        "group": {
          "name": "registry"
        },
        "path": "/var/lib/registry/certs",
        "user": {
          "name": "registry"
        },
        "mode": 493
      }
    ],
    "files": [
      {
        "group": {
          "name": "root"
        },
        "overwrite": true,
        "path": "/etc/hostname",
        "user": {
          "name": "root"
        },
        "contents": {
          "source": "data:,helper.ocp.bmlab.int",
          "verification": {}
        },
        "mode": 420
      },
      {
        "group": {
          "name": "haproxy"
        },
        "path": "/etc/haproxy/haproxy.cfg",
        "user": {
          "name": "haproxy"
        },
        "contents": {
          "source": "data:,global%0A%20%20%20%20log%20%20%20%20127.0.0.1%20local0%20notice%0A%20%20%20%20daemon%0A%0Adefaults%0A%20%20%20%20mode%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20http%0A%20%20%20%20default-server%20%20%20%20%20%20%20%20%20%20%20%20init-addr%20last%2Clibc%2Cnone%0A%20%20%20%20log%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20global%0A%20%20%20%20option%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20httplog%0A%20%20%20%20option%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20dontlognull%0A%20%20%20%20option%20%20http-server-close%0A%20%20%20%20option%20%20forwardfor%20%20%20%20%20%20%20%20except%20127.0.0.0%2F8%0A%20%20%20%20option%20%20redispatch%0A%20%20%20%20timeout%20http-request%20%20%20%20%20%2010s%0A%20%20%20%20timeout%20queue%20%20%20%20%20%20%20%20%20%20%20%20%201m%0A%20%20%20%20timeout%20connect%20%20%20%20%20%20%20%20%20%20%2010s%0A%20%20%20%20timeout%20client%20%20%20%20%20%20%20%20%20%20%20%201m%0A%20%20%20%20timeout%20server%20%20%20%20%20%20%20%20%20%20%20%201m%0A%20%20%20%20timeout%20http-keep-alive%20%20%2010s%0A%20%20%20%20timeout%20check%20%20%20%20%20%20%20%20%20%20%20%20%2010s%0A%20%20%20%20retries%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%203%0A%0Aresolvers%20dns%0A%20%20nameserver%20dns1%20%2010.0.0.1%3A53%0A%20%20resolve_retries%20%203%0A%20%20timeout%20resolve%20%201s%0A%20%20timeout%20retry%20%20%20%201s%0A%20%20hold%20%20%20%20other%20%20%20%2030s%0A%20%20hold%20%20%20%20refused%20%2030s%0A%20%20hold%20%20%20%20nx%20%20%20%20%20%20%2030s%0A%20%20hold%20%20%20%20timeout%20%2030s%0A%20%20hold%20%20%20%20valid%20%20%20%2010s%0A%20%20hold%20%20%20%20obsolete%2030s%0A%0Alisten%20stats%0A%20%20%20%20bind%20*%3A5555%0A%20%20%20%20stats%20enable%0A%20%20%20%20stats%20uri%20%2Fhaproxy%3Fstats%0A%0Afrontend%20openshift-api-server%0A%20%20%20%20bind%20*%3A6443%0A%20%20%20%20default_backend%20openshift-apiserver%0A%20%20%20%20mode%20tcp%0A%20%20%20%20option%20tcplog%0A%0Abackend%20openshift-apiserver%0A%20%20%20%20balance%20source%0A%20%20%20%20mode%20tcp%0A%20%20%20%20server%20bootstrap%20bootstrap.ocp.bmlab.int%3A6443%20check%20resolvers%20dns%0A%20%20%20%20server%20master00%20%20master00.ocp.bmlab.int%3A6443%20%20check%20resolvers%20dns%0A%20%20%20%20server%20master01%20%20master01.ocp.bmlab.int%3A6443%20%20check%20resolvers%20dns%0A%20%20%20%20server%20master02%20%20master02.ocp.bmlab.int%3A6443%20%20check%20resolvers%20dns%0A%0Afrontend%20machine-config-server%0A%20%20%20%20bind%20*%3A22623%0A%20%20%20%20default_backend%20machine-config-server%0A%20%20%20%20mode%20tcp%0A%20%20%20%20option%20tcplog%0A%0Abackend%20machine-config-server%0A%20%20%20%20balance%20source%0A%20%20%20%20mode%20tcp%0A%20%20%20%20server%20bootstrap%20bootstrap.ocp.bmlab.int%3A22623%20check%20resolvers%20dns%0A%20%20%20%20server%20master00%20%20master00.ocp.bmlab.int%3A22623%20%20check%20resolvers%20dns%0A%20%20%20%20server%20master01%20%20master01.ocp.bmlab.int%3A22623%20%20check%20resolvers%20dns%0A%20%20%20%20server%20master02%20%20master02.ocp.bmlab.int%3A22623%20%20check%20resolvers%20dns%0A%0Afrontend%20ingress-http%0A%20%20%20%20bind%20*%3A80%0A%20%20%20%20default_backend%20ingress-http%0A%20%20%20%20mode%20tcp%0A%20%20%20%20option%20tcplog%0A%0Abackend%20ingress-http%0A%20%20%20%20balance%20source%0A%20%20%20%20mode%20tcp%0A%20%20%20%20server%20infra00%20master00.ocp.bmlab.int%3A80%20check%20resolvers%20dns%0A%20%20%20%20server%20infra01%20master01.ocp.bmlab.int%3A80%20check%20resolvers%20dns%0A%20%20%20%20server%20infra02%20master02.ocp.bmlab.int%3A80%20check%20resolvers%20dns%0A%0Afrontend%20ingress-https%0A%20%20%20%20bind%20*%3A443%0A%20%20%20%20default_backend%20ingress-https%0A%20%20%20%20mode%20tcp%0A%20%20%20%20option%20tcplog%0A%0Abackend%20ingress-https%0A%20%20%20%20balance%20source%0A%20%20%20%20mode%20tcp%0A%20%20%20%20server%20infra00%20master00.ocp.bmlab.int%3A443%20check%20resolvers%20dns%0A%20%20%20%20server%20infra01%20master01.ocp.bmlab.int%3A443%20check%20resolvers%20dns%0A%20%20%20%20server%20infra02%20master02.ocp.bmlab.int%3A443%20check%20resolvers%20dns%0A",
          "verification": {}
        },
        "mode": 416
      },
      {
        "group": {
          "name": "root"
        },
        "overwrite": true,
        "path": "/etc/registry/configuration.env",
        "user": {
          "name": "root"
        },
        "contents": {
          "source": "data:,REGISTRY_AUTH%3Dhtpasswd%0AREGISTRY_AUTH_HTPASSWD_REALM%3DRegistry%20credentials%0AREGISTRY_AUTH_HTPASSWD_PATH%3D%2Fauth%2Fhtpasswd%0AREGISTRY_HTTP_TLS_CERTIFICATE%3D%2Fcerts%2Fcertificate.pem%0AREGISTRY_HTTP_TLS_KEY%3D%2Fcerts%2Fprivate.key%0AREGISTRY_COMPATIBILITY_SCHEMA1_ENABLED%3Dtrue%0A",
          "verification": {}
        },
        "mode": 420
      },
      {
        "group": {
          "name": "root"
        },
        "overwrite": true,
        "path": "/var/lib/registry/auth/htpasswd",
        "user": {
          "name": "root"
        },
        "contents": {
          "source": "data:,ocp%3A%242y%2405%240XLfYiGz6o8N24R3lG.d..JjnSUJVC9WnM5H0RzriZ6r9ESizdCci%0A",
          "verification": {}
        },
        "mode": 420
      },
      {
        "group": {
          "name": "root"
        },
        "overwrite": true,
        "path": "/var/lib/registry/certs/certificate.pem",
        "user": {
          "name": "root"
        },
        "contents": {
          "source": "data:,CHANGE_ME%0A",
          "verification": {}
        },
        "mode": 420
      },
      {
        "group": {
          "name": "root"
        },
        "overwrite": true,
        "path": "/var/lib/registry/certs/private.key",
        "user": {
          "name": "root"
        },
        "contents": {
          "source": "data:,CHANGE_ME%0A",
          "verification": {}
        },
        "mode": 420
      }
    ]
  },
  "systemd": {
    "units": [
      {
        "contents": "[Unit]\nDescription=HAProxy\nDocumentation=https://www.haproxy.org/\nAfter=network-online.target\nWants=network-online.target\n\n[Service]\nType=simple\nTimeoutStartSec=180\nStandardOutput=journal\nExecStartPre=-/bin/podman pull docker.io/haproxy:${ha_proxy_version}\nExecStart=/bin/podman run --name %n --rm \\\n    --publish 80:80 \\\n    --publish 443:443 \\\n    --publish 6443:6443 \\\n    --publish 5555:5555 \\\n    --publish 22623:22623 \\\n    --volume  /etc/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro,z \\\n    docker.io/haproxy:${ha_proxy_version}\nRestart=on-failure\nRestartSec=5\nExecStop=/bin/podman stop %n\nExecReload=/bin/podman restart %n\n\n[Install]\nWantedBy=multi-user.target\n",
        "enabled": true,
        "name": "haproxy.service"
      },
      {
        "contents": "[Unit]\nDescription=Registry\nDocumentation=https://hub.docker.com/_/registry\nAfter=network-online.target\nWants=network-online.target\n\n[Service]\nType=simple\nTimeoutStartSec=180\nStandardOutput=journal\nExecStartPre=-/bin/podman pull docker.io/registry:${registry_version}\nExecStart=/bin/podman run --name %n --rm \\\n    --publish  5000:5000 \\\n    --env-file /etc/registry/configuration.env \\\n    --volume   /var/lib/registry/data:/var/lib/registry:z \\\n    --volume   /var/lib/registry/auth:/auth:ro,z \\\n    --volume   /var/lib/registry/certs:/certs:ro,z \\\n    docker.io/registry:${registry_version}\nRestart=on-failure\nRestartSec=5\nExecStop=/bin/podman stop %n\nExecReload=/bin/podman restart %n\n\n[Install]\nWantedBy=multi-user.target\n",
        "enabled": true,
        "name": "registry.service"
      }
    ]
  }
}