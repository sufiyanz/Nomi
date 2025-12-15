import Foundation

// MARK: - Predefined Vocabulary

enum PredefinedVocabulary {
    
    /// Returns the English words for a given location
    static func words(for location: Location) -> [String] {
        switch location {
        case .home:
            return homeWords
        case .cafe:
            return cafeWords
        case .restaurant:
            return restaurantWords
        case .office:
            return officeWords
        case .groceryStore:
            return groceryStoreWords
        case .transit:
            return transitWords
        case .cinema:
            return cinemaWords
        case .gym:
            return gymWords
        case .park:
            return parkWords
        case .hospital:
            return hospitalWords
        }
    }
    
    // MARK: - Home
    
    private static let homeWords = [
        "Sofa",
        "Television",
        "Remote Control",
        "Lamp",
        "Bookshelf",
        "Pillow",
        "Blanket",
        "Clock",
        "Mirror",
        "Curtain",
        "Bed",
        "Wardrobe",
        "Desk",
        "Chair",
        "Plant",
        "Rug",
        "Picture Frame",
        "Door",
        "Window",
        "Key"
    ]
    
    // MARK: - Café
    
    private static let cafeWords = [
        "Coffee",
        "Tea",
        "Croissant",
        "Muffin",
        "Latte",
        "Espresso",
        "Cup",
        "Saucer",
        "Sugar",
        "Milk",
        "Menu",
        "Table",
        "Chair",
        "Barista",
        "Cake",
        "Cookie",
        "Napkin",
        "Straw",
        "Lid",
        "Receipt"
    ]
    
    // MARK: - Restaurant
    
    private static let restaurantWords = [
        "Menu",
        "Fork",
        "Knife",
        "Spoon",
        "Plate",
        "Glass",
        "Napkin",
        "Waiter",
        "Bill",
        "Table",
        "Chair",
        "Salt",
        "Pepper",
        "Bread",
        "Water",
        "Wine",
        "Appetizer",
        "Main Course",
        "Dessert",
        "Tip"
    ]
    
    // MARK: - Office
    
    private static let officeWords = [
        "Computer",
        "Keyboard",
        "Mouse",
        "Monitor",
        "Desk",
        "Chair",
        "Printer",
        "Stapler",
        "Paper",
        "Pen",
        "Notebook",
        "Calendar",
        "Phone",
        "Meeting",
        "Email",
        "Colleague",
        "Boss",
        "Coffee Mug",
        "Whiteboard",
        "File"
    ]
    
    // MARK: - Grocery Store
    
    private static let groceryStoreWords = [
        "Cart",
        "Basket",
        "Aisle",
        "Shelf",
        "Cashier",
        "Receipt",
        "Bag",
        "Fruit",
        "Vegetable",
        "Bread",
        "Milk",
        "Cheese",
        "Meat",
        "Fish",
        "Frozen Food",
        "Snack",
        "Drink",
        "Price",
        "Sale",
        "Queue"
    ]
    
    // MARK: - Transit
    
    private static let transitWords = [
        "Train",
        "Platform",
        "Ticket",
        "Seat",
        "Window",
        "Door",
        "Conductor",
        "Announcement",
        "Delay",
        "Schedule",
        "Map",
        "Station",
        "Luggage",
        "Passenger",
        "Track",
        "Express",
        "Local",
        "Transfer",
        "Exit",
        "Entrance"
    ]
    
    // MARK: - Cinema
    
    private static let cinemaWords = [
        "Screen",
        "Seat",
        "Ticket",
        "Popcorn",
        "Soda",
        "Movie",
        "Trailer",
        "Poster",
        "Lobby",
        "Snack Bar",
        "3D Glasses",
        "Subtitle",
        "Row",
        "Exit",
        "Armrest",
        "Speaker",
        "Showtime",
        "Aisle",
        "Curtain",
        "Credit"
    ]
    
    // MARK: - Gym
    
    private static let gymWords = [
        "Treadmill",
        "Dumbbell",
        "Barbell",
        "Bench",
        "Mat",
        "Towel",
        "Water Bottle",
        "Locker",
        "Mirror",
        "Weight",
        "Machine",
        "Trainer",
        "Membership",
        "Class",
        "Stretch",
        "Exercise",
        "Rep",
        "Set",
        "Rest",
        "Warm Up"
    ]
    
    // MARK: - Park
    
    private static let parkWords = [
        "Tree",
        "Grass",
        "Bench",
        "Path",
        "Flower",
        "Pond",
        "Duck",
        "Bird",
        "Squirrel",
        "Playground",
        "Swing",
        "Slide",
        "Fountain",
        "Picnic",
        "Blanket",
        "Dog",
        "Bicycle",
        "Jogger",
        "Trash Can",
        "Shade"
    ]
    
    // MARK: - Hospital/Pharmacy
    
    private static let hospitalWords = [
        "Doctor",
        "Nurse",
        "Patient",
        "Medicine",
        "Prescription",
        "Pharmacy",
        "Waiting Room",
        "Appointment",
        "Reception",
        "Insurance",
        "Symptom",
        "Pain",
        "Fever",
        "Cough",
        "Bandage",
        "Injection",
        "Blood Test",
        "X-Ray",
        "Emergency",
        "Wheelchair"
    ]
}
