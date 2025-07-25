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

  # Returns the appropriate Tailwind CSS classes for flash messages
  # @param [String] type the type of flash message (notice, alert, etc.)
  # @return [String] Tailwind CSS classes
  def flash_class(type)
    base_classes = "p-4 mb-4 rounded-lg"
    case type.to_sym
    when :alert
      "#{base_classes} bg-red-100 text-red-700 dark:bg-red-200 dark:text-red-800"
    when :notice
      "#{base_classes} bg-green-100 text-green-700 dark:bg-green-200 dark:text-green-800"
    else
      "#{base_classes} bg-blue-100 text-blue-700 dark:bg-blue-200 dark:text-blue-800"
    end
  end
end
