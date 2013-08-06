# Finding various UUIDs needed by the JSON files

## Catalog Item UUID

* Authorization:

        curl -v -X POST -d '' -H "Accept: application/*+xml;version=5.1" -u "username@org-name:password" "https://vendor-api-endpoint/api/sessions"

  - The above returns x-vcloud-authorization token
  - The abpve request returns xml, which contains the reference to the organisation details url, similar to below

            <Link rel="down" type="application/vnd.vmware.vcloud.org+xml" name="org-name" href="https://vendor-api-endpoint/api/org/{org-uuid}"/>

* Get org details:

        curl -v --insecure -H "x-vcloud-authorization: <token>" -H "Accept: application/*+xml;version=5.1" https://vendor-api-endpoint/api/org/{org-uuid}

  - The above returns catalog details. (In vcloud you have a catalog which is a group pf catalogItems i.e templates)

            <Link rel="down" type="application/vnd.vmware.vcloud.catalog+xml" name="Default" href="https://vendor-api-endpoint/api/catalog/{catalog-uuid}"/>

* Get catalog items

        curl -v --insecure -H "x-vcloud-authorization: {token}" -H "Accept: application/*+xml;version=5.1" https://vendor-api-endpoint/api/catalog/{catalog-uuid}

  - The above returns all the catalogItems in the catalog, you can choose the desired one

            <CatalogItem type="application/vnd.vmware.vcloud.catalogItem+xml" name="{catalog-item-name}" href="https://vendor-api-endpoint/api/catalogItem/{catalog-item-uuid}"/>


