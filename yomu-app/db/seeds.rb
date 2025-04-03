books = [
  { title: "1984", author: "George Orwell", genre: "Dystopian", total_pages: 328, isbn: "9780451524935" },
  { title: "To Kill a Mockingbird", author: "Harper Lee", genre: "Classic", total_pages: 281, isbn: "9780060935467" },
  { title: "The Great Gatsby", author: "F. Scott Fitzgerald", genre: "Classic", total_pages: 180, isbn: "9780743273565" },
  { title: "Harry Potter and the Sorcerer's Stone", author: "J.K. Rowling", genre: "Fantasy", total_pages: 309, isbn: "9780590353427" },
  { title: "The Hobbit", author: "J.R.R. Tolkien", genre: "Fantasy", total_pages: 310, isbn: "9780547928227" }
]

books.each do |book|
  Book.create!(book)
end

TriviaQuestion.create!(
  book: Book.find_by(title: "1984"),
  question: "What is the name of the totalitarian regime in the book?",
  answer: "Big Brother",
  difficulty: 1
)

TriviaQuestion.create!(
  book: Book.find_by(title: "To Kill a Mockingbird"),
  question: "What is the name of the Finch family's neighbor?",
  answer: "Boo Radley",
  difficulty: 1
)

perks = [
  { name: "Speed Reader", description: "50% bonus points for reading sessions", required_points: 1000 },
  { name: "Book Worm", description: "Special profile badge", required_points: 2000 },
  { name: "Literary Scholar", description: "Access to exclusive challenges", required_points: 5000 },
  { name: "Master Reviewer", description: "Reviews worth double points", required_points: 3000 }
]

perks.each do |perk|
  Perk.create!(perk)
end

puts "Seed data created successfully!"
