module MailHelper
  def rating_to_letter_grade(rating)
    grade = ""

    case rating
    when 1
      grade = "A+"
    when 2
      grade = "A"
    when 3
      grade = "A-"
    when 4
      grade = "B+"
    when 5
      grade = "B"
    when 6
      grade = "B-"
    when 7
      grade = "C+"
    when 8
      grade = "C"
    when 9
      grade = "C-"
    when 10
      grade = "D+"
    when 11
      grade = "D"
    when 12
      grade = "D-"
    when 13
      grade = "F"
    else
      grade = ""
    end

    return grade
  end
end