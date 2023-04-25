import Foundation

//MARK: properties

enum PriceRange{
    case low
    case medium
    case high
}

enum Location {
    case ny
    case la
    case ch
    
    var name: String {
        switch self {
        case .ny:
            return "New York"
        case .la:
            return "Los Angeles"
        case .ch:
            return "Chicago"
        }
    }
}

protocol Located {
    var location: Location { get set }
}

protocol Priced{
    var priceRange: PriceRange { get set }
}

//MARK: product

struct Product: Priced, Located {
    var name: String
    var location: Location
    var priceRange: PriceRange
}

extension Product: CustomStringConvertible{
    var description: String{
        return name
    }
}

//MARK: specifiaction

protocol Specification{
    associatedtype T
    
    func isSatisfied(item: T) -> Bool
}

struct LocationSpec<T:Located>: Specification{
    var location: Location
    func isSatisfied(item: T) -> Bool {
        return item.location == location
    }
}

struct PriceRangeSpec<T:Priced>: Specification{
    var priceRange: PriceRange
    func isSatisfied(item: T) -> Bool {
        return item.priceRange == priceRange
    }
}

//MARK: filter

protocol Filter{
    associatedtype T

    func filter<Spec:Specification> (items: [T], spec: Spec) -> [T]
    where Spec.T == T
}

struct GenericFilter<T>: Filter{
    func filter<Spec>(items: [T], spec: Spec) -> [T] where Spec : Specification, T == Spec.T {
        var output = [T]()
        for item in items{
            if spec.isSatisfied(item: item){
                output.append(item)
            }
        }
        return output
    }
}


//MARK: use case

let restaurant1 = Product(name: "Restaurant 1", location: .ny, priceRange: .high)
let hotel1 = Product(name: "Hotel 1", location: .la, priceRange: .medium)
let restaurant2 = Product(name: "Restaurant 2", location: .la, priceRange: .high)
let hotel2 = Product(name: "Hotel 2", location: .ch, priceRange: .low)
let products = [restaurant1, restaurant2, hotel1, hotel2]
let mediumPriceSpec = PriceRangeSpec<Product>(priceRange: .medium)
let laLocationSpec = LocationSpec<Product>(location: .la)

let mediumPriceProducts = GenericFilter().filter(items: products, spec: mediumPriceSpec)
print(mediumPriceProducts)

let laLocatedProducts = GenericFilter().filter(items: products, spec: laLocationSpec)
print(laLocatedProducts)

