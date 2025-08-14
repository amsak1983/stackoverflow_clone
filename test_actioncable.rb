#!/usr/bin/env ruby
# Test script to verify ActionCable functionality
# Run this from Rails console: load 'test_actioncable.rb'

puts "Testing ActionCable Broadcasting..."

# Test Questions Channel
puts "\n1. Testing Questions Channel Broadcasting:"
ActionCable.server.broadcast(
  "questions",
  {
    action: "create",
    html: "<div class='test-question'>Test Question Broadcast</div>"
  }
)
puts "✓ Questions broadcast sent"

# Test Answers Channel
puts "\n2. Testing Answers Channel Broadcasting:"
ActionCable.server.broadcast(
  "questions/1/answers",
  {
    html: "<div class='test-answer'>Test Answer Broadcast</div>"
  }
)
puts "✓ Answers broadcast sent for question 1"

# Test Comments Channel
puts "\n3. Testing Comments Channel Broadcasting:"
ActionCable.server.broadcast(
  "questions_1_comments",
  {
    html: "<div class='test-comment'>Test Comment Broadcast</div>",
    dom_id: "comment_test",
    commentable_type: "Question",
    commentable_id: 1
  }
)
puts "✓ Comments broadcast sent for question 1"

puts "\nActionCable test broadcasts completed!"
puts "Check browser console for connection logs and received data."
