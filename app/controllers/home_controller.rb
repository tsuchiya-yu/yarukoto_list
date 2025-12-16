class HomeController < ApplicationController
  def index
    render inertia: "Home", props: {
      message: "引越し前後のやることを一緒に確認しましょう。"
    }
  end
end
