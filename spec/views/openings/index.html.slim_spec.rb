require 'spec_helper'

require 'will_paginate/array'

describe "openings/index" do
  before(:each) do
    assign(:search, Opening.search(:title_cont => 'Title'))
    assign(:openings, [
      stub_model(Opening,
        :title => "Title"
      ),
      stub_model(Opening,
                 :title => "Title"
      ),
      stub_model(Opening,
                 :title => "Title"
      ),
      stub_model(Opening,
        :title => "Title"
      )
    ].paginate(:page => 1, :per_page => 2))
  end

  it "renders a list of openings and give readonly access button" do
    render :template => "openings/index_anonymous"

    assert_select "tr>td", :text => "Title".to_s, :count => 2
    expect(rendered).not_to include "View Mine"
    expect(rendered).not_to include "View All"
    expect(rendered).not_to include "Add a Job Opening"
  end

  it "renders a list of openings and give write access if suitable" do
    sign_in_as_admin
    render
    expect(rendered).to include "Add a Job Opening"
    expect(rendered).to include "Edit"
    expect(rendered).to include "Delete"
  end

  it "switch between view-all and view-mine" do
    sign_in_as_admin
    render
    expect(rendered).to include "View All"
    render :template => 'openings/index', :locals => { :mine => true }
    expect(rendered).to include "View All"
    render :template => 'openings/index', :locals => { :all => true }
    expect(rendered).to include "View Mine"
  end

end
