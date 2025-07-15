module ApplicationHelper
  # Helper methods for the application

  # Format the date in a more readable way
  # @param [DateTime] date the date to format
  # @return [String] formatted date string
  def formatted_date(date)
    date.strftime("%B %d, %Y at %H:%M")
  end

  # Calculate time ago in a more readable format
  # @param [DateTime] date the date to calculate from
  # @return [String] formatted time ago string
  def time_ago(date)
    time_ago_in_words(date) + " ago"
  end
end
