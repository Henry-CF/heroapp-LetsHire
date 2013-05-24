require 'spec_helper'

describe 'openings/new' do

  before(:each) do

    assign(:opening, stub_model(Opening,
      :title => 'MyString'
    ).as_new_record)

    assign(:current_user, stub_model(User,
      :id => 1
    ).as_new_record)

  end

  it 'renders new opening form' do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'form', :action => openings_path, :method => 'post' do
      assert_select 'input#opening_title', :name => 'opening[title]'
    end
  end
end
