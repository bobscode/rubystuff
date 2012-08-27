class ArizonaCustomerNotesController < ApplicationController

  layout "archive"
  def require_single_token
    if current_user.nil?
      render :text => "Unauthorized", :status => :unauthorized
    end
  end

  def index
    Time.zone = "Pacific Time (US & Canada)"
    @arizona_customer_notes = ArizonaCustomerNote.paginate(:page => params[:page], :per_page => 10).where(:customer_id => params[:customer_id])
    respond_to do |format|
       format.html # index.html.erb
       format.json { render json: @arizona_customer_notes }
    end
  end

  def show
    Time.zone = "Pacific Time (US & Canada)"
    @arizona_customer_note = ArizonaCustomerNote.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @arizona_customer_note }
    end
  end

  def new
    @arizona_customer_note = ArizonaCustomerNote.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @arizona_customer_note }
    end
  end

  # GET /arizona_customer_notes/1/edit
  def edit
    @arizona_customer_note = ArizonaCustomerNote.find(params[:id])
  end

  # POST /arizona_customer_notes
  # POST /arizona_customer_notes.json
  def create
    @arizona_customer_note = ArizonaCustomerNote.new(params[:arizona_customer_note])

    respond_to do |format|
      if @arizona_customer_note.save
        format.html { redirect_to @arizona_customer_note, notice: 'Arizona customer note was successfully created.' }
        format.json { render json: @arizona_customer_note, status: :created, location: @arizona_customer_note }
      else
        format.html { render action: "new" }
        format.json { render json: @arizona_customer_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /arizona_customer_notes/1
  # PUT /arizona_customer_notes/1.json
  def update
    @arizona_customer_note = ArizonaCustomerNote.find(params[:id])

    respond_to do |format|
      if @arizona_customer_note.update_attributes(params[:arizona_customer_note])
        format.html { redirect_to @arizona_customer_note, notice: 'Arizona customer note was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @arizona_customer_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /arizona_customer_notes/1
  # DELETE /arizona_customer_notes/1.json
  def destroy
    @arizona_customer_note = ArizonaCustomerNote.find(params[:id])
    @arizona_customer_note.destroy

    respond_to do |format|
      format.html { redirect_to arizona_customer_notes_url }
      format.json { head :no_content }
    end
  end
end
