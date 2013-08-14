# Finding various UUIDs needed by the JSON files

Using: [VCloud Tools](https://github.com/alphagov/vcloudtools)


## Logging into VCloud

```
#$> export VCLOUD_API_ROOT=https://api.vcd.example.com/api eval `vcloud-login`
Please log into vCloud
Username: username@organisation
Password:
```

## Finding Catalog and VM Template UUIDs


### Finding the organisation uuid
 
```
#$> vcloud-browse /org | grep MyOrg
    <Org type="application/vnd.vmware.vcloud.org+xml" name="MyOrg" href="https://api.vcd.example.com/api/org/77595ec2-2391-4817-9257-66b12533d684"/>
```

In this example, the Org UUID is `77595ec2-2391-4817-9257-66b12533d684`

### Finding the catalog

```
#$> vcloud-browse /org/77595ec2-2391-4817-9257-66b12533d684 | grep vcloud.catalog+xml
    <Link rel="down" type="application/vnd.vmware.vcloud.catalog+xml" name="Private" href="https://api.vcd.example.com/api/catalog/9250924f-20af-4bcc-9f50-1125a2c15d2c"/>
    <Link rel="down" type="application/vnd.vmware.vcloud.catalog+xml" name="Public Catalogue" href="https://api.vcd.example.com/api/catalog/b695b0f0-1abf-4562-bd4a-d64cf133888b"/>
    <Link rel="down" type="application/vnd.vmware.vcloud.catalog+xml" name="Default" href="https://api.vcd.example.com/api/catalog/3af329ef-3371-49d4-aaa0-0b98a03a9255"/>
```

This lists three possible catalogs, Private, Default and Public Catalogue (yours may be named differently, or you may have a different number of them.)

In the next example, we will use the UUID of the "Public Catalogue" which is `b695b0f0-1abf-4562-bd4a-d64cf133888b`

### Finding Templates within a Catalog

```
[/Users/ssharpe]$ vcloud-browse /catalog/b695b0f0-1abf-4562-bd4a-d64cf133888b | grep catalogItem+xml
        <CatalogItem type="application/vnd.vmware.vcloud.catalogItem+xml" name="Ubuntu 12.04 Desktop" href="https://api.vcd.example.com/api/catalogItem/4e376bed-5d4c-4748-9d0d-1469b24f31c0"/>
        <CatalogItem type="application/vnd.vmware.vcloud.catalogItem+xml" name="Ubuntu 12.04 Server" href="https://api.vcd.example.com/api/catalogItem/4887d502-5873-4d0c-bb63-075792277ec6"/>
```

## Finding Network UUIDs

```
#$> vcloud-browse /org/0e665418-a3d5-4363-aec0-f2da5ab399d9 | grep orgNetwork
<Link rel="down" type="application/vnd.vmware.vcloud.orgNetwork+xml" name="Net1" href="https://api.vcd.example.com/api/network/e22af121-cdaf-455b-b840-1d7283aaeca7"/>
<Link rel="down" type="application/vnd.vmware.vcloud.orgNetwork+xml" name="Net2" href="https://api.vcd.example.com/api/network/59defffb-f6b7-47b8-a82c-80a8bc3fc76b"/>
<Link rel="down" type="application/vnd.vmware.vcloud.orgNetwork+xml" name="Net3" href="https://api.vcd.example.com/api/network/91ae3fdb-e354-426c-be79-4911f7c5dbdb"/>
```