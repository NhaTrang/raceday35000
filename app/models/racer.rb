class Racer
  include Mongoid::Document
  include ActiveModel::Model
  
  #Add attributes to the Racer class that allow one to set/get each of the following properties:
  #id,number,first_name,last_name,gender,group,secs
  
  attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs


 
  def self.mongo_client
  	db = Mongo::Client.new('mongodb://localhost:27017')
  end


  def self.collection
  	self.mongo_client['racers']
  end

    #The method accept an optional prototype, optional sort, optional skip, and optional limit.
    #The default for the prototype is to “match all” – which means you must provide it a document that matches all records. 
    #The default for sort must be by number ascending. 
    #The default for skip must be 0 and the default for limit must be nil.
    #find all racers that match the given prototype
    #sort them by the given hash criteria
    #skip the specified number of documents
    #limit the number of documents returned if limit is specified
    #return the result
    
  def self.all(prototype={}, sort={:number => 1}, skip=0, limit=nil)    
  	result=collection.find(prototype)
  	.sort(sort) 
  	.skip(skip)     
  	if !limit.nil?
  		result = result.limit(limit)
  	end
    	result  
  end

  #Add an initializer that can set the properties of the class using the keys from a racers document. It must:
  #accept a hash of properties
  #assign instance attributes to the values from the hash
  #for the id property, this method must test whether the hash is coming from a web page [:id] or from a
  #MongoDB query [:_id] and assign the value to whichever is non-nil.

  def initialize(params={})
  	@id=params[:_id].nil? ? params[:id] : params[:_id].to_s
  	@number=params[:number].to_i
  	@first_name=params[:first_name]
  	@last_name=params[:last_name]
  	@gender=params[:gender]
  	@group=params[:group]
  	@secs=params[:secs].to_i
  end

  #accept a single id parameter that is either a string or BSON::ObjectId Note: it must be able to handle either format.
  #find the specific document with that _id
  #return the racer document represented by that id
    
  def self.find(id)
  	result=collection.find(:_id => BSON::ObjectId.from_string(id))
  					 .projection({_id:true, number:true, first_name:true, last_name:true, gender:true, group:true, secs:true})
  					 .first
  	return result.nil? ? nil : Racer.new(result)
  end


  def save
  	result=self.class.collection.insert_one(number:@number, first_name: @first_name, 
  		last_name: @last_name, gender: @gender, group: @group, secs: @secs)
  	@id=result.inserted_id.to_s
  end
  
  #accept a hash as an input parameter
  #updates the state of the instance variables – except for @id. That never should change.
  #find the racer associated with the current @id instance variable in the database
  #update the racer with the supplied values – replacing all values

  
  def update(params)
  	@number=params[:number].to_i
  	@first_name=params[:first_name]
  	@last_name=params[:last_name]
  	@secs=params[:secs].to_i
  	@gender=params[:gender]
  	@group=params[:group]
  	
  	params.slice!(:number, :first_name, :last_name, :gender, :group, :secs)
	self.class.collection
	            .find(:_id=>BSON::ObjectId.from_string(@id))
	            .replace_one(params)
  	
  end

  #accept no arguments
  #find the racer associated with the current @number instance variable in the database
  #remove that instance from the database

  def destroy
  	self.class.collection.find(_id:BSON::ObjectId.from_string(@id)).delete_one()
  
  end

  #accept no arguments
  #return true when @id is not nil. Remember – we assigned @id during save when we obtained the generated primary key.
  
  def persisted?
  	!@id.nil?
  end

  #accept no arguments
  #return nil or whatever date you would like. This is, of course, just a placeholder until we implement something that does this for real.
  
  def created_at
  	nil
  end
  def updated_at
  	nil
  end

  #accept a hash as input parameters
  #extract the :page property from that hash, convert to an integer, and default to the value of 1 if not set.
  #extract the :per_page property from that hash, convert to an integer, and default to the value of 30 if not set
  #find all racers sorted by number assending.
  #limit the results to page and limit values.
  #convert each document hash to an instance of a Racer class
  #Return a WillPaginate::Collection with the page, limit, and total values filled in – as well as the page worth of data.
  
  def self.paginate(params)
    page=(params[:page] || 1).to_i
    limit=(params[:per_page] || 30).to_i
    skip=(page-1)*limit
    sort = params[:first_name] || {}

    racers=[]
    all({}, sort, skip, limit).each do |doc|
      racers << Racer.new(doc)
    end

    total = all().count

    WillPaginate::Collection.create(page, limit, total) do |pager|
      pager.replace(racers)
    end
  end

end
