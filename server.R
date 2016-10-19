library(shiny)
library(gentelellaShiny)
library(googleAuthR)
library(googleAnalyticsR)
library(googleID)
library(DT)

options(shiny.port = 1221)
options(googleAuthR.scopes.selected = c("https://www.googleapis.com/auth/userinfo.email",
                                        "https://www.googleapis.com/auth/userinfo.profile",
                                        "https://www.googleapis.com/auth/analytics.readonly"))

function(input, output, session){
  
  access_token <- callModule(googleAuthR::googleAuth, "auth",
                             login_text = "Log in",
                             logout_text = "Log off",
                             access_type = "online")
  
  ga_tables <- reactive({
    
    req(access_token())
    
    with_shiny(google_analytics_account_list,
               shiny_access_token = access_token())
    
  })
  
  user_data <- reactive({
    
    req(access_token())
    ## user_data$emails$value
    ## user_data$displayName
    ## user_data$image$url
    with_shiny(get_user_info,
               shiny_access_token = access_token())
    
  })
  
  output$profile <- renderUI({
    
    req(user_data())
    
    ud <- user_data()
    
    profile_box(ud$displayName, ud$image$url)
    
    
  })
  
  output$profile_nav <- renderUI({
    
    req(user_data())
    
    ud <- user_data()
    
    profile_nav(ud$displayName, ud$image$url, list(tags$li(tags$a(href="javascript:;", " Profile")),
                                                   tags$li(
                                                     tags$a(href="javascript:;", " Settings")
                                                   ),
                                                   tags$li(
                                                     tags$a(href="javascript:;", "Help")
                                                   ),
                                                   tags$li(
                                                     tags$a(href="/", tags$i(class="fa fa-sign-out pull-right"), "Log out"
                                                     ))))
    
    
  })
  
  selected_id <- callModule(authDropdown, "auth_dropdown", ga_tables)
  
  dl_data <- eventReactive( input$do_fetch, {
    
    req(access_token())
    req(selected_id())
    req(input$metric_select)
    req(input$dimension_select)
    req(input$date_select)
    
    with_shiny(
      google_analytics_4,
      viewId = selected_id(),
      date_range = c(input$date_select[1], input$date_select[2]),
      metrics = input$metric_select,
      dimensions = input$dimension_select,
      anti_sample = TRUE,
      max = -1,
      shiny_access_token = access_token()
    )
    
  })
  
  ## download data
  output$data_table <- DT::renderDataTable({
    
    req(dl_data())
    
    DT::datatable(dl_data())
    
  })
  
  output$do_download <- downloadHandler(
    filename = function(){
      paste0("unsampled-ga-data-",isolate(selected_id()),"-",Sys.Date(),".csv")
    },
    content = function(file){
      write.csv(dl_data(), file, row.names = FALSE)
    }
  )
  
}