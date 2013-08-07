# Organisation & Machine JSON files

## Tree structure

    .
    ├── machines
    │   └── tester
    │       ├── machine-1.json
    │       └── machine-2.json
    ├── orgs
        ├── org1.json
        └── org2.json

## Organisation JSON file format

Each organisation JSON file contains key value pair to represent meta data for
the same. An example is as follows

    {
      "default": {
        "template_name": "<catalog-item-name>",
        "host": "<api-vendor-endpoint>",
        "platform": "<platform-name>",
        "organisation": "<org-name>",
        "catalog_items": {
          "<catalog-item-name": "https://api.vcd.portal.skyscapecloud.com/api/catalogItem/<catalog-item-uuid>"
        }
      },
      "<vdc-ref-name/zone>": {
        "default_vdc": "https://api.vcd.portal.skyscapecloud.com/api/vdc/<vdc-uuid>",
        "network_name": "<network-name>",
        "network_uri": "https://api.vcd.portal.skyscapecloud.com/api/network/<network-uuid>",
        "vdc_id": "<vdc-uuid>"
      }
    }

* catalog is a terminology used by vcloud to represent templates used as base
  images
* org-name is the name of organisation on which you would be bringing up the
  machines.
* vdc-ref-name/zone, is an non vcloud specific term, which we use to map the
  machines to a particular network. You would see the reference to the value
  in machine JSON file.
* default_vdc, is the herf to vdc network.
* network-name, can be found out from vcloud UI `Adminstration -> Your VDC -> Org VDC Networks -> the network you would use it for`

To find various uuids, please refer [here](/docs/uuids.md)

Note: We would be removing platform from the settings, as it is currently only
used to set facter variables on the newly set up machine.

## Machine JSON file format

Each machine JSON file contain key value pair to represent machine specific
meta data

    {
      "class":            "classname",
      "zone":             "<vdc-ref-name/zone>",
      "vm_name":          "vm-machine-name",
      "ip":               "<internal-ip-addr>"
    }

* class key is used to set class name as a facter variable. This will soon be removed
* zone, is the reference to <vdc-ref-name/zone> used in organisation json
* vm-machine-name, is the name of vApp
* ip is the internal ip addr that would be used.
