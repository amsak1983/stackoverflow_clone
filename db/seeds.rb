# This file creates sample data for the Stack Overflow clone application
# Run with: rails db:seed

# Clear existing data to avoid duplicates
puts "Cleaning database..."
Question.destroy_all

# Create sample questions
puts "Creating questions..."
questions = [
  {
    title: "How to use Active Record in Rails?",
    body: "I'm new to Rails and would like to know how to properly use Active Record for database operations. What are the best practices?"
  },
  {
    title: "Differences between has_many and has_many :through",
    body: "What's the difference between has_many and has_many :through relationships in Rails? When should I use each of them?"
  },
  {
    title: "How to set up RSpec in a Rails project?",
    body: "I want to add tests to my Rails project. How do I properly set up RSpec and what gems should I add?"
  },
  {
    title: "Problem with validation in Rails",
    body: "When saving my model, I'm getting a validation error, but I can't figure out what's wrong. What's the best way to debug validations in Rails?"
  },
  {
    title: "How to implement authentication in Rails?",
    body: "What are the different ways to implement user authentication in Rails? Should I use Devise or build my own solution?"
  }
]

# Create questions and answers
created_questions = []
questions.each do |question_data|
  question = Question.create!(
    title: question_data[:title],
    body: question_data[:body],
    created_at: rand(1..30).days.ago
  )
  created_questions << question
  puts "Created question: #{question.title}"

  # Create 1-3 answers for each question
  rand(1..3).times do |i|
    answer = question.answers.create!(
      body: "Answer #{i+1} to the question about #{question.title.downcase}. This contains a detailed explanation with code examples and recommendations.",
      created_at: rand(1..question.created_at.to_i).seconds.ago
    )
    puts "  - Created answer #{i+1} for question: #{question.title}"
  end
end

puts "Seed data created successfully!"
puts "Created #{Question.count} questions and #{Answer.count} answers."
