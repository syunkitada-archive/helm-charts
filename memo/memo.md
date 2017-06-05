# MEMO

## ドメイン名はすべてFQDNにする
* FQDNでないと、クエリを一回失敗してからsearchlistでのクエリとなるので遅くなる:
  * 特に、eventletでFQDNでない場合にクエリが数秒遅くなってしまう

``` python
# /opt/glance/lib/python3.5/site-packages/eventlet/support/greendns.py

    def query(self, qname, rdtype=dns.rdatatype.A, rdclass=dns.rdataclass.IN,
              tcp=False, source=None, raise_on_no_answer=True,
              _hosts_rdtypes=(dns.rdatatype.A, dns.rdatatype.AAAA)):
        """Query the resolver, using /etc/hosts if enabled.

        Behavior:
        1. if hosts is enabled and contains answer, return it now
        2. query nameservers for qname
        3. if qname did not contain dots, pretend it was top-level domain,
           query "foobar." and append to previous result

        ....

        # Main query
        # FQDNの場合はここで解決できる
        step(self._resolver.query, qname, rdtype, rdclass, tcp, source, raise_on_no_answer=False)

        # `resolv.conf` docs say unqualified names must resolve from search (or local) domain.
        # However, common OS `getaddrinfo()` implementations append trailing dot (e.g. `db -> db.`)
        # and ask nameservers, as if top-level domain was queried.
        # This step follows established practice.
        # https://github.com/nameko/nameko/issues/392
        # https://github.com/eventlet/eventlet/issues/363
        if len(qname) == 1:
            # FQDNでない場合、ここに入りsearch listから名前解決しようとする
            # これが数秒かかってしまう
            step(self._resolver.query, qname.concatenate(dns.name.root),
                 rdtype, rdclass, tcp, source, raise_on_no_answer=False)
```
