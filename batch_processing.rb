def process(p,store)
  begin  
    cat_img_list = p.fetch_image_paths    
    p.catalog_images = cat_img_list unless cat_img_list.empty?    
    p.save!    
    @s_count += 1        
  rescue Exception => e    
    @errors[p[:product_id]] = e
    File.open('log/' + store.name + 'batch_load_errors', 'a+') { |file| file.write(p[:product_id].to_s + ' ' + e.to_s) }        
    @f_count += 1    
    print "x(#{p[:product_id]})"    
  end    
end  
 
 
def batch_process(products,store,batch_size = 100,start_from = 1,alert = 10)
  @s_count = 0  
  @f_count = 0  
  @errors = {}  
  print "Started batch process =>"  
  products.each_slice(batch_size).with_index {|(*batch),batch_index|  
  if batch_index + 1 >= start_from
     batch.each_with_index do |p,item_index|    
      process(p,store)      
      print (((item_index + 1) % alert).zero? ? (item_index + 1) : ".")            
     end        
     @current_batch = batch_index + 1
     puts "\n== #{(batch_index + 1).ordinalize} Batch Over - Success Count - #{@s_count} - Failure Count - #{@f_count} =="
  end  
  }  
  puts "\nGod bless you, @errors hash contains all your errors"
 
rescue
  puts "rescued from big loop error, starting next batch.."
 batch_process(products,store,batch_size,@current_batch + 1)  
end
