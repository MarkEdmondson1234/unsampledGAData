library(shiny)
library(gentelellaShiny)
library(googleAnalyticsR)

options(shiny.port = 1221)
options(googleAuthR.scopes.selected = c("https://www.googleapis.com/auth/userinfo.email",
                                        "https://www.googleapis.com/auth/userinfo.profile",
                                        "https://www.googleapis.com/auth/analytics.readonly"))

menuItems <- list(
  sideBarElement(" Contact ",
                 icon = icon("envelope"),
                 list(a(href="mailto:mark@iihnordic.com",
                        HTML(paste(icon("email"), "Support"))),
                      a(href="https://analytics.google.com/analytics/web/#management/Settings/a130829w114272913p119395418/",
                        HTML(paste(icon("google"), " Google Analytics")))
                      )
  ),
  sideBarElement(column(width = 12, googleAuthR::googleAuthUI("auth"),
                        icon = NULL)
  ))

meta <- googleAnalyticsR::meta

gentelellaPage(
  column(width = 12, googleAnalyticsR::authDropdownUI("auth_dropdown", inColumns = TRUE)),
  tagList(
    column(width = 3,
           selectInput("dimension_select", "Select Dimensions", 
                       choices = allowed_metric_dim("DIMENSION"), multiple = TRUE, width = "80%")
           ),
    column(width = 3,
           selectInput("metric_select", "Select Metrics", 
                       choices = allowed_metric_dim("METRIC"), multiple = TRUE, width = "80%")
           ),
    column(width = 3,
           dateRangeInput("date_select", "Select Dates", 
                          start = Sys.Date() - 31, end = Sys.Date() - 1,
                          width = "80%")
    ),
    column(width = 3,
           br(),
           actionButton("do_fetch", "Fetch Unsampled Data", class = "btn btn-primary"),
           helpText("Please push button only once and be patient for big data fetches.")
           )
            ),
  dashboard_box(width = 12, box_title = "Unsampled data", menuItems = NULL, height = 800,
                conditionalPanel("output.data_table", downloadButton("do_download", class = "btn btn-info")),
                DT::dataTableOutput("data_table")
                
    
    
  ),
  menuItems = menuItems,
  title_tag = "IIH Nordic GA Helper",
  site_title = a(class="site_title", icon("eye"), span("IIH Nordic"))
)