json.id @product.id
json.sku @product.sku
json.name @product.name
json.brand @product.brand
json.description @product.description
json.price @product.price
json.is_bundle @product.is_bundle
if @product.is_bundle?
    json.components @product.components do |component|
      json.id component.id
      json.name component.name
      json.price component.price
    end
end
