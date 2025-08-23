# StackOverflow Clone

A functional clone of StackOverflow built with Ruby on Rails 8. This application allows users to ask questions, provide answers, vote on content, and earn reputation points.

## Features

* User authentication and profiles
* Question asking and answering
* Voting system for questions and answers
* Comment functionality
* Tags and categories
* User reputation system
* Search functionality

## Technical Stack

* Ruby on Rails 8
* Ruby version: 3.x
* Database: PostgreSQL
* Frontend: ERB templates, JavaScript, CSS

## Setup and Installation

### Prerequisites

* Ruby 3.x
* Rails 8.1
* PostgreSQL

### Installation Steps

```bash
# Clone the repository
git clone https://github.com/amsak1983/stackoverflow_clone
cd stackoverflow_clone

# Install dependencies
bundle install

# Setup database
rails db:create
rails db:migrate
rails db:seed # Optional: adds sample data

# Start the server
rails server
```

Visit `http://localhost:3000` in your browser to access the application.

## Testing

```bash
rails test
```
