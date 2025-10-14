puts "Cleaning database..."
Vote.destroy_all if defined?(Vote)
Comment.destroy_all if defined?(Comment)
Link.destroy_all if defined?(Link)
Reward.destroy_all if defined?(Reward)
Answer.destroy_all if defined?(Answer)
Question.destroy_all if defined?(Question)
User.destroy_all

puts "Creating users..."

users_data = [
  { email: "john.doe@example.com", name: "John Doe", password: "john2024secure" },
  { email: "alice.smith@example.com", name: "Alice Smith", password: "alice_dev123" },
  { email: "bob.johnson@example.com", name: "Bob Johnson", password: "bob!secure99" },
  { email: "emma.wilson@example.com", name: "Emma Wilson", password: "emma@rails2024" },
  { email: "mike.brown@example.com", name: "Mike Brown", password: "mikebrown_pass" }
]

users = []
puts "\n" + "="*60
puts "Creating users with credentials:"
puts "="*60

users_data.each do |user_data|
  user = User.create!(
    email: user_data[:email],
    password: user_data[:password],
    password_confirmation: user_data[:password],
    confirmed_at: Time.current
  )
  users << user
  puts "✓ Email: #{user.email.ljust(30)} | Password: #{user_data[:password]}"
end

puts "="*60

puts "Creating questions..."
questions = [
  {
    title: "How to deploy Rails application with Kamal?",
    body: "I want to deploy my Rails 8 application using Kamal. What are the basic steps? I have a VPS with Ubuntu. Need help with configuration and setup."
  },
  {
    title: "Sidekiq not processing background jobs",
    body: "My Sidekiq workers are running but jobs stay in the queue and never get processed. Redis connection is fine. What could be wrong?"
  },
  {
    title: "Best way to send emails in Rails production?",
    body: "I'm getting SMTP timeout errors when sending emails. My hosting provider blocks port 587. What are alternative solutions for sending transactional emails?"
  },
  {
    title: "How to use Active Record associations?",
    body: "I'm learning Rails and confused about has_many, belongs_to and has_many :through. Can someone explain with simple examples when to use each?"
  },
  {
    title: "Docker volume permissions issue",
    body: "Getting 'permission denied' when trying to access SQLite database from Docker container. How do I fix volume permissions?"
  },
  {
    title: "TailwindCSS not loading styles in production",
    body: "My TailwindCSS styles work fine in development but don't load in production after deployment. Asset pipeline is configured. What am I missing?"
  },
  {
    title: "How to implement real-time features with ActionCable?",
    body: "I want to add real-time notifications to my Rails app. Should I use ActionCable or something else? Looking for a simple tutorial."
  },
  {
    title: "RSpec vs Minitest - which is better?",
    body: "Starting a new Rails project. Should I use RSpec or stick with Minitest? What are the pros and cons of each testing framework?"
  },
  {
    title: "Optimizing database queries in Rails",
    body: "My application is slow with N+1 queries. I've heard about includes, joins, and eager loading. What's the difference and when should I use each?"
  },
  {
    title: "Authentication with Devise: setup guide",
    body: "New to Devise gem. How do I set it up properly? Need basic authentication with email confirmation and password reset functionality."
  }
]

# Create questions and answers
created_questions = []
answers_data = {
  0 => [ # Kamal deployment
    "First, install Kamal: `gem install kamal`. Then run `kamal init` in your project. Configure deploy.yml with your server details and run `kamal setup` followed by `kamal deploy`.",
    "Check out the official Kamal documentation. You'll need Docker on your VPS. Basic steps: 1) Setup SSH keys 2) Configure deploy.yml 3) Run kamal setup 4) Deploy with kamal deploy. Make sure ports 80/443 are open."
  ],
  1 => [ # Sidekiq not processing
    "Check if Sidekiq is listening to the correct queue. Your jobs might be in 'mailers' queue but Sidekiq only processes 'default'. Add the queue to config/sidekiq.yml under :queues section.",
    "Also verify that Sidekiq container has access to the same Redis instance as your app. Use `Sidekiq::Queue.new('default').size` to check queue size."
  ],
  2 => [ # Email sending
    "Use SendGrid or Mailgun API instead of SMTP. They provide HTTP APIs that bypass port restrictions. SendGrid free tier gives 100 emails/day. Just add their gem and configure with API key.",
    "Another option is Amazon SES. It's cheap and reliable. You can also try port 2525 which some providers don't block."
  ],
  3 => [ # Active Record associations
    "belongs_to: child model has foreign key. has_many: parent can have multiple children. Example: User has_many :posts, Post belongs_to :user. Use has_many :through for many-to-many like User has_many :groups, through: :memberships.",
    "Think of it like parent-child. belongs_to = this record belongs to another. has_many = this record owns many others. Through adds a join table in between for complex relationships."
  ],
  4 => [ # Docker permissions
    "Add volumes with proper permissions in your docker-compose or Kamal config. Make sure the app user inside container matches the volume owner. You can also run `chown -R rails:rails /rails/storage` in your Dockerfile.",
    "Check your Dockerfile USER directive. SQLite needs write access to the directory. Mount volumes with correct user:group mapping."
  ],
  5 => [ # TailwindCSS production
    "Run `rails assets:precompile` before deployment. Make sure your build:css npm script runs during Docker build. Check if RAILS_SERVE_STATIC_FILES=true is set in production.",
    "Verify that application.css imports your tailwind css file. Also check that NODE_ENV=production during build so Tailwind purges unused styles correctly."
  ],
  6 => [ # ActionCable real-time
    "ActionCable is built into Rails! Create a channel: `rails g channel Notifications`. Subscribe in JavaScript with `consumer.subscriptions.create`. Broadcast from server with `ActionCable.server.broadcast`.",
    "For simple notifications, ActionCable is perfect. For complex real-time features, consider AnyCable for better performance. Check Rails guides for complete ActionCable tutorial."
  ],
  7 => [ # RSpec vs Minitest
    "RSpec has more readable syntax and powerful matchers. Minitest is simpler and included with Rails. For beginners, Minitest is easier. For large teams, RSpec's expressiveness helps. Both are excellent choices.",
    "I prefer RSpec for its describe/context/it syntax. It makes tests read like documentation. But Minitest is faster and has less magic. Choose based on team preference."
  ],
  8 => [ # Query optimization
    "Use `includes` for eager loading to prevent N+1: `User.includes(:posts)`. Use `joins` for filtering: `User.joins(:posts).where(posts: {status: 'published'})`. Install bullet gem to detect N+1 queries in development.",
    "The key difference: includes loads associated records (2 queries), joins just filters (1 query but doesn't load). Use select to limit columns: `User.select(:id, :email)` for better performance."
  ],
  9 => [ # Devise setup
    "Add gem 'devise' to Gemfile, run bundle install, then `rails generate devise:install`. Follow the instructions, then `rails generate devise User`. Run migrations. Configure mailer settings in config/environments.",
    "Devise is great for quick auth setup. After generation, customize views with `rails generate devise:views`. Enable confirmable module in your User model for email confirmation."
  ]
}

questions.each_with_index do |question_data, index|
  random_user = users.sample

  question = Question.create!(
    title: question_data[:title],
    body: question_data[:body],
    user: random_user,
    created_at: rand(1..30).days.ago
  )
  created_questions << question
  puts "Created question: #{question.title}"

  # Create answers for this question
  question_answers = answers_data[index] || []
  question_answers.each_with_index do |answer_body, answer_index|
    answer_user = users.sample
    
    answer = question.answers.create!(
      body: answer_body,
      user: answer_user,
      created_at: question.created_at + rand(1..48).hours,
      best: answer_index == 0 && rand < 0.5 # 50% chance first answer is marked as best
    )
    puts "  ✓ Created answer by #{answer_user.email}"
  end
end

puts "\n" + "="*70
puts "🎉 Seed data created successfully!"
puts "="*70
puts "📊 Statistics:"
puts "   Users: #{User.count}"
puts "   Questions: #{Question.count}"
puts "   Answers: #{Answer.count}"
puts "\n🔐 Login Credentials:"
puts "-"*70

users_data.each do |user_data|
  puts "   Email: #{user_data[:email].ljust(35)} | Password: #{user_data[:password]}"
end

puts "="*70
