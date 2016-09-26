namespace :pages do
  desc "Generate pages: Faq, Products, Contact, About and Checkout"
  task :generate_pages => :environment do
    puts "== Generating Pages \n"
    Page.where(name: "About").first_or_create(name:"About",title:"About",body:"Content for about page")
    Page.where(name: "Product").first_or_create(name:"Product",title:"Product",body:"Content for Products page")
    Page.where(name: "Checkout").first_or_create(name:"Checkout",title:"Checkout",body:"Content for Checkout page")
    Page.where(name: "Contact").first_or_create(name:"Contact",title:"Contact",body:"Content for Contact page")
    Page.where(name: "Faq").first_or_create(name:"Faq",title:"Faq",body:"Content for Faq page")
    Page.where(name: "New Restaurant How it works").first_or_create(name:"New Restaurant How it works",title:"How it works",body:"Content for New Restaurant page")
  end
end
