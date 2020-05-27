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
        "mode": 488
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
          "source": "data:,global%0A%20%20%20%20log%20%20%20%20127.0.0.1%20local0%20notice%0A%20%20%20%20daemon%0A%0Adefaults%0A%20%20%20%20mode%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20http%0A%20%20%20%20default-server%20%20%20%20%20%20%20%20%20%20%20%20init-addr%20last%2Clibc%2Cnone%0A%20%20%20%20log%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20global%0A%20%20%20%20option%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20httplog%0A%20%20%20%20option%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20dontlognull%0A%20%20%20%20option%20%20http-server-close%0A%20%20%20%20option%20%20forwardfor%20%20%20%20%20%20%20%20except%20127.0.0.0%2F8%0A%20%20%20%20option%20%20redispatch%0A%20%20%20%20timeout%20http-request%20%20%20%20%20%2010s%0A%20%20%20%20timeout%20queue%20%20%20%20%20%20%20%20%20%20%20%20%201m%0A%20%20%20%20timeout%20connect%20%20%20%20%20%20%20%20%20%20%2010s%0A%20%20%20%20timeout%20client%20%20%20%20%20%20%20%20%20%20%20%201m%0A%20%20%20%20timeout%20server%20%20%20%20%20%20%20%20%20%20%20%201m%0A%20%20%20%20timeout%20http-keep-alive%20%20%2010s%0A%20%20%20%20timeout%20check%20%20%20%20%20%20%20%20%20%20%20%20%2010s%0A%20%20%20%20retries%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%203%0A%0Afrontend%20openshift-api-server%0A%20%20%20%20bind%20*%3A6443%0A%20%20%20%20default_backend%20openshift-apiserver%0A%20%20%20%20mode%20tcp%0A%20%20%20%20option%20tcplog%0A%0Abackend%20openshift-apiserver%0A%20%20%20%20balance%20source%0A%20%20%20%20mode%20tcp%0A%20%20%20%20server%20bootstrap%20bootstrap.ocp.bmlab.int%3A6443%20check%0A%20%20%20%20server%20master00%20%20master00.ocp.bmlab.int%3A6443%20%20check%0A%20%20%20%20server%20master01%20%20master01.ocp.bmlab.int%3A6443%20%20check%0A%20%20%20%20server%20master02%20%20master02.ocp.bmlab.int%3A6443%20%20check%0A%0Afrontend%20machine-config-server%0A%20%20%20%20bind%20*%3A22623%0A%20%20%20%20default_backend%20machine-config-server%0A%20%20%20%20mode%20tcp%0A%20%20%20%20option%20tcplog%0A%0Abackend%20machine-config-server%0A%20%20%20%20balance%20source%0A%20%20%20%20mode%20tcp%0A%20%20%20%20server%20bootstrap%20bootstrap.ocp.bmlab.int%3A22623%20check%0A%20%20%20%20server%20master00%20%20master00.ocp.bmlab.int%3A22623%20%20check%0A%20%20%20%20server%20master01%20%20master01.ocp.bmlab.int%3A22623%20%20check%0A%20%20%20%20server%20master02%20%20master02.ocp.bmlab.int%3A22623%20%20check%0A%0Afrontend%20ingress-http%0A%20%20%20%20bind%20*%3A80%0A%20%20%20%20default_backend%20ingress-http%0A%20%20%20%20mode%20tcp%0A%20%20%20%20option%20tcplog%0A%0Abackend%20ingress-http%0A%20%20%20%20balance%20source%0A%20%20%20%20mode%20tcp%0A%20%20%20%20server%20infra00%20master00.ocp.bmlab.int%3A80%20check%0A%20%20%20%20server%20infra01%20master01.ocp.bmlab.int%3A80%20check%0A%20%20%20%20server%20infra02%20master02.ocp.bmlab.int%3A80%20check%0A%0Afrontend%20ingress-https%0A%20%20%20%20bind%20*%3A443%0A%20%20%20%20default_backend%20ingress-https%0A%20%20%20%20mode%20tcp%0A%20%20%20%20option%20tcplog%0A%0Abackend%20ingress-https%0A%20%20%20%20balance%20source%0A%20%20%20%20mode%20tcp%0A%20%20%20%20server%20infra00%20master00.ocp.bmlab.int%3A443%20check%0A%20%20%20%20server%20infra01%20master01.ocp.bmlab.int%3A443%20check%0A%20%20%20%20server%20infra02%20master02.ocp.bmlab.int%3A443%20check%0A%0Alisten%20stats%0A%20%20%20%20bind%20*%3A5555%0A%20%20%20%20stats%20enable%0A%20%20%20%20stats%20uri%20%2Fhaproxy%3Fstats%0A",
          "verification": {}
        },
        "mode": 416
      }
    ]
  },
  "systemd": {
    "units": [
      {
        "contents": "[Unit]\nDescription=HAProxy\nDocumentation=https://www.haproxy.org/\nAfter=network-online.target\nWants=network-online.target\n\n[Service]\nType=simple\nTimeoutStartSec=180\nStandardOutput=journal\nExecStartPre=-/bin/podman pull docker.io/haproxy:${ha_proxy_version}\nExecStart=/bin/podman run --name %n --rm \\\n    --publish  80:80 \\\n    --publish  443:443 \\\n    --publish  6443:6443 \\\n    --publish  5555:5555 \\\n    --publish  22623:22623 \\\n    --volume   /etc/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro,z \\\n    docker.io/haproxy:${ha_proxy_version}\nRestart=on-failure\nRestartSec=5\nExecStop=/bin/podman stop %n\nExecReload=/bin/podman restart %n\n\n[Install]\nWantedBy=multi-user.target\n",
        "enabled": true,
        "name": "haproxy.service"
      }
    ]
  }
}