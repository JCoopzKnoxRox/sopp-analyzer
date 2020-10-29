require 'csv'
require 'set'
require 'date'
require 'time'

# processing data from Stanford Open Policing Project data:
# https://openpolicing.stanford.edu/data/


def outcome_types(filename)
    result = Set.new
    # Note that:
    # %i[numeric date] == [:numeric, :date]
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        result << row['outcome']
    end
    return result
end


def outcome_types2(filename)
    # uses inject in a clever way!
    result = CSV.foreach(filename, headers: true, converters: %i[numeric date]).inject(Set.new) do |result, row|
        result << row['outcome']
    end
    return result
end

def outcome_types3(filename)
    # can just return the result of the inject() call
    return CSV.foreach(filename, headers: true, converters: %i[numeric date]).inject(Set.new) do |result, row|
        result << row['outcome']
    end
end


def any_type_set(filename, key)
    return CSV.foreach(filename, headers: true, converters: %i[numeric date]).inject(Set.new) do |result, row|
        result << row[key]
    end
end


def any_type_hash(filename, key)
    # key is the name of any column header for a row
    result = Hash.new(0)
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        result[row[key]] += 1
        puts result[row[key]]
    end
    return result
end
def CO_violation_hash(filename) #nested hash funciton was used for multiple purposes
    result = Hash.new
    sum = 0;
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        violation = row['outcome']
        countyname = row['county_name']
        subjectrace = row['subject_race']
        if (( countyname == "Arapahoe County" || countyname == "Adams County"))
        if !result.include?(violation)
            temp1 = Hash.new
            temp1[subjectrace] = 1
            result[countyname] = temp1
        elsif result.include?(violation)
            temp2 = result[countyname]
            if !temp2.include?(subjectrace)
                temp2[subjectrace] = 0
            elsif temp2.include?(subjectrace)
                temp2[subjectrace] += 1
            end
        end
        sum += 1
        puts sum
        end
    end
    result
end
def CO_race_age_comp(filename)
    result = Hash.new
    sum = 0;
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        age = row['subject_age']
        countyname = row['county_name']
        if (row["subject_race"] == "white" && (countyname == "Arapahoe County" || countyname == "Denver County" || countyname == "Adams County"))
            if !result.include?(countyname)
                temp = Array.new
                result[countyname] = temp
                result[countyname].push(age)
            elsif result.include?(countyname)
                result[countyname].push(age)
            end
            sum += 1
            puts sum
        end
    end
    result.each_value {|value| value.delete("NA") }
    result
end

def CO_age_hash(filename)
result = Hash.new
sum = 0;
CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
    age = row['subject_age']
    countyname = row['county_name']
    if (countyname == "Arapahoe County" || countyname == "Denver County" || countyname == "Adams County")
        if !result.include?(countyname)
            temp = Array.new
            result[countyname] = temp
            result[countyname].push(age)
        elsif result.include?(countyname)
        result[countyname].push(age)
        end
        sum += 1
        puts sum
    end
    result
end

result.each_value {|value| value.delete("NA") }
result
end

def search_conducted(filename)
    arrestedandsearch = 0
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        if(row['subject_race'] == "white" && row['outcome'] == "arrest"  && row['search_conducted'] == "TRUE" && (row['county_name'] == "Denver County"))
            arrestedandsearch +=1
        end
        puts arrestedandsearch
    end
end

def officer_checker(filename)
    result = Hash.new
    sum = 0;
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        ofiicersex= row['officer_sex']
        countyName = row['county_name']
        if(row["search_conducted"] == "TRUE" &&(countyName== "Denver County"))
        if !result.include?(countyName)
            temp1 = Hash.new
            temp1[ofiicersex] = 1
            result[countyName] = temp1
        elsif result.include?(countyName)
            temp2 = result[countyName]
            if !temp2.include?(ofiicersex)
                temp2[ofiicersex] = 0
            elsif temp2.include?(ofiicersex)
                temp2[ofiicersex] += 1
            end

        end
        end
        sum+=1
        puts sum
    end
    result
end

def cwday(date)
    return date.cwday
end


def hour(time)
    return time.split(':')[0].to_i
end


def any_type_hash2(filename, key, func=nil)
    # func is a function that does more processing on a column value
    # so for example, we may want to convert a time like "19:30:56" to just 19
    # or get the day of the week for a date like "2017-03-12"
    result = Hash.new(0)
    sum = 0
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        new_key = row[key]
        if func != nil
            new_key = func.call(new_key)
        end
        result[new_key] += 1
        sum += 1
        puts sum
    end
    return result
end


def any_type_hash3(filename, key, func=nil)
    # Using inject() is tricky with a Hash
    return CSV.foreach(filename, headers: true, converters: %i[numeric date]).inject(Hash.new(0)) do |result, row|
        new_key = row[key]
        if func != nil
            new_key = func.call(new_key)
        end
        result[new_key] += 1
        # THIS LINE IS NECESSARY! inject() needs a return value after processing
        # each row to assign to the next version of result
        result
    end
end


def parse_all(filename)
    outcomes = Hash.new(0)
    days = Hash.new(0)
    hours = Hash.new(0)
    CSV.foreach(filename, headers: true, converters: %i[numeric date]) do |row|
        outcomes[row['outcome']] += 1
        days[row['date'].cwday] += 1
        hours[hour(row['time'])] += 1
    end
    puts outcomes
    puts days
    puts hours
end


if __FILE__ == $0
  co = 'co_statewide_data.csv'
  cos = 'co_short.csv'
  aur = 'co_aurora.csv'
  den = 'co_denver.csv'
  va = 'va_statewide_data.csv'
  #vas = 'va_short.csv'
  # vt = 'vt_burlington_short.csv'
  #wy = 'wy_statewide_2020_04_01.csv'

  #p outcome_types(cos)
  #p CO_violation_hash(co);
  ages = CO_race_age_comp(co)
  puts ages
  for age in ages.values do
   puts "Mean/Average: " + (age.sum(0.0) / age.size).to_s
    puts "Min Age: " + age.min.to_s
    puts "Max Age: " + age.max.to_s
   age.sort
   puts "Median Age: " + age[age.length/2].to_s
   puts "\n"
  end
  #p search_conducted(co);
  #p outcome_types2(cos)
    #p outcome_types3(vt)
    #p any_type_set(vt, 'outcome')
    #p any_type_set(vt, 'raw_race')
    #p any_type_set(vt, 'subject_race')
    
  #p day_of_week(vas)
    #p day_of_week(vt).sort_by(&:first).map(&:last)

  #p any_type_hash(co, 'time')

    #p any_type_hash2(vt, 'date', method(:cwday)).sort_by(&:first).map(&:last)
  #hashVA = any_type_hash2(va, 'county_name')
  #p any_type_hash2(va, 'county_name')
  #hashVA.delete("NA")
  #savedVal = hashVA.values.max
  #savedKey = hashVA.key(savedVal)
  #p hash
  #puts savedKey
  #puts savedVal
  #puts i
  #puts CO_violation_hash(cos)
  #p officer_checker(co)
  #puts any_type_hash(den, 'arrest_made')
    #p any_type_hash2(vt, 'violation')
    #p any_type_hash2(vt, 'time', method(:hour)).sort_by(&:first).map(&:last)

    #parse_all(vt)

  end