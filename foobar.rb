def foobar(n)
  return if n <= 0  # 0以下の場合は何も出力しない

  (1..n).each do |i|
    if i % 3 == 0 && i % 5 == 0
      puts "foobar"
    elsif i % 3 == 0
      puts "foo"
    elsif i % 5 == 0
      puts "bar"
    else
      puts i
    end
  end
end
