










#' Title
#'
#' @param input
#' @param vars
#' @param time
#' @param status
#' @param time_point
#' @param time_type
#' @param palette
#' @param cols
#' @param seed
#' @param show_col
#' @param path
#' @param main
#' @param index
#' @param fig.type
#' @param width
#' @param height
#'
#' @return
#' @export
#'
#' @examples
roc_time <- function(input, vars, time = "time", status = "status", time_point = 12, time_type = "month",
                     palette = "jama", cols = "normal", seed = 1234, show_col = FALSE,  path = NULL, main = "PFS", index = 1,
                     fig.type = "pdf", width = 5, height = 5.2){


  if(!is.null(path)){
    file_store<-path
  }else{
    file_store<-paste0("ROC-time")
  }

  path<- creat_folder(file_store)
  ##############################################
  cols <- get_cols(cols = cols, palette = palette, show_col = show_col, seed = seed)
  ##############################################

  input <- as.data.frame(input)
  input<- input[,colnames(input)%in%c(time, status, vars)]
  #filter data
  colnames(input)[which(colnames(input)==time)]<-"time"
  colnames(input)[which(colnames(input)==status)]<-"status"
  ##############################################
  input$time<-as.numeric(input$time)
  if(time_type=="day") input$time<-input$time/30

  input$status<-as.numeric(as.character(input$status))
  input<- input %>%
    dplyr::filter(!is.na(time)) %>%
    dplyr::filter(!is.na(status)) %>%
    dplyr::filter(!.$time=="NA") %>%
    dplyr::filter(!.$status=="NA") %>%
    dplyr::filter(.$time > 0)
  ###################################
  print(paste0(">>>-- Range of Time: "))
  print(range(input$time))
  ###################################
  # input$time<-as.numeric(input$time)
  # input$status<-as.numeric(input$status)
  input <- as.data.frame(input)
  ###################################
  time <- input[, "time"]
  status <- input[, "status"]
  ###################################


  ####################################
  if(length(vars)==1){

    message(">>>--- For one variable, `time_point`: Three different times can be set")

    if(length(time_point)==1) time_point<- round(c(quantile(time)[2],quantile(time)[3],quantile(time)[4]), 0)
    ###################################
    roc1      <- timeROC::timeROC( T        = time,
                          delta             = status,
                          marker            = input[, vars],
                          cause             =1,
                          weighting         ="marginal",
                          times             = time_point[1],
                          iid               =TRUE)
    auc1 <- round(roc1[["AUC"]][2],2)
    #########################################
    roc2      <- timeROC::timeROC( T        = time,
                          delta    = status,
                          marker   = input[, vars],
                          cause    =1,
                          weighting="marginal",
                          times    = time_point[2],
                          iid      =TRUE)
    auc2 <- round(roc2[["AUC"]][2],2)
    #########################################
    roc3      <- timeROC::timeROC( T        = time,
                          delta    = status,
                          marker   = input[, vars],
                          cause    =1,
                          weighting="marginal",
                          times    = time_point[3],
                          iid      =TRUE)
    auc3 <- round(roc3[["AUC"]][2],2)
    #########################################

    p<- ggplot() +
      geom_line( aes(x = roc1$FP[,2], y = roc1$TP[,2]),color = cols[1]) +
      geom_line( aes(x = roc2$FP[,2], y = roc2$TP[,2]),color = cols[2])+
      geom_line( aes(x = roc3$FP[,2], y = roc3$TP[,2]),color = cols[3])+

      geom_line(aes(x=c(0,1),y=c(0,1)),color = "grey", linetype = "dashed" )+
      theme_light()+
      annotate("text",x = .7, y = .35, label = paste("AUC of ", time_point[1]," month = ", auc1),color = cols[1])+
      annotate("text",x = .7, y = .25, label = paste("AUC of ", time_point[2], " month = ", auc2),color = cols[2])+
      annotate("text",x = .7, y = .15, label = paste("AUC of ", time_point[3], " month = ", auc3),color = cols[3])+
      scale_x_continuous(name  = "False Positive Rate")+
      scale_y_continuous(name = "True Positive Rate")+
      ggtitle(paste0(vars, ", ", main, " = ", paste0(time_point, collapse = ", "), " month"))

  }

  if(length(vars)==2){

    var1 <- vars[1]
    var2 <- vars[2]
    var3 <- paste0( var1, " + ", var2)
    #cox regression
    marker3 <- coxph(Surv(time, status)~ input[,var1] + input[,var2], data = input)
    input$var3 <-predict(marker3, type = "lp", newdata = input)

    roc1      <- timeROC::timeROC( T        = time,
                          delta    = status,
                          marker   = input[, var1],
                          cause    =1,
                          weighting="marginal",
                          times    = time_point,
                          iid      =TRUE)
    auc1 <- round(roc1[["AUC"]][2],2)
    #########################################
    roc2      <- timeROC::timeROC( T        = time,
                          delta    = status,
                          marker   = input[, var2],
                          cause    = 1,
                          weighting="marginal",
                          times    = time_point,
                          iid      =TRUE)
    auc2 <- round(roc2[["AUC"]][2],2)
    #########################################
    roc3      <- timeROC::timeROC( T        = time,
                          delta    = status,
                          marker   = input$var3,
                          cause    = 1,
                          weighting="marginal",
                          times    = time_point,
                          iid      =TRUE)
    auc3 <- round(roc3[["AUC"]][2],2)
    #########################################
    p<- ggplot() +
      geom_line( aes(x = roc1$FP[,2], y = roc1$TP[,2]),color = cols[1]) +
      geom_line( aes(x = roc2$FP[,2], y = roc2$TP[,2]),color = cols[2])+
      geom_line( aes(x = roc3$FP[,2], y = roc3$TP[,2]),color = cols[3])+

      geom_line(aes(x=c(0,1),y=c(0,1)),color = "grey", linetype = "dashed" )+
      theme_light()+
      annotate("text",x = .7, y = .35, label = paste("AUC of ", var1," = ", auc1),color = cols[1])+
      annotate("text",x = .7, y = .25, label = paste("AUC of ", var2, " = ", auc2),color = cols[2])+
      annotate("text",x = .7, y = .15, label = paste("AUC of ", var3, " = ", auc3),color = cols[3])+
      scale_x_continuous(name  = "False Positive Rate")+
      scale_y_continuous(name = "True Positive Rate")+
      ggtitle(paste0(main, " = ", time_point, " month"))

  }



  if(length(vars)==3){
    var1 <- vars[1]
    var2 <- vars[2]
    var3 <- vars[3]
    var4 <- paste0( var1, "+", var2, "+", var3)
    #cox regression
    marker4 <- coxph(Surv(time, status)~ input[,var1] + input[,var2] + input[,var3], data = input)
    input$var4 <-predict(marker4, type = "lp", newdata = input)

    message(">>=== Predicting combined score...")
    roc1      <- timeROC::timeROC( T        = time,
                          delta    = status,
                          marker   = input[, var1],
                          cause    =1,
                          weighting="marginal",
                          times    = time_point,
                          iid      =TRUE)
    auc1 <- round(roc1[["AUC"]][2],2)
    #########################################
    roc2      <- timeROC::timeROC( T        = time,
                          delta    = status,
                          marker   = input[, var2],
                          cause    = 1,
                          weighting="marginal",
                          times    = time_point,
                          iid      =TRUE)
    auc2 <- round(roc2[["AUC"]][2],2)
    #########################################
    roc3      <- timeROC::timeROC( T        = time,
                          delta    = status,
                          marker   = input[, var3],
                          cause    = 1,
                          weighting="marginal",
                          times    = time_point,
                          iid      =TRUE)
    auc3 <- round(roc3[["AUC"]][2],2)
    #########################################
    roc4      <- timeROC::timeROC( T        = time,
                          delta    = status,
                          marker   = input$var4,
                          cause    = 1,
                          weighting="marginal",
                          times    = time_point,
                          iid      =TRUE)
    auc4 <- round(roc4[["AUC"]][2],2)

    # print(data.frame(roc4$TP[, 2], roc4$FP[, 2]))
    # print(data.frame(roc3$TP[, 2], roc3$FP[, 2]))
    # print(data.frame(roc2$TP[, 2], roc2$FP[, 2]))
    # print(data.frame(roc1$TP[, 2], roc1$FP[, 2]))
    # print(cols)
    #########################################

    p<- ggplot() +
      geom_line( aes(x = roc1$FP[,2], y = roc1$TP[,2]),color = cols[1]) +
      geom_line( aes(x = roc2$FP[,2], y = roc2$TP[,2]),color = cols[2])+
      geom_line( aes(x = roc3$FP[,2], y = roc3$TP[,2]),color = cols[3])+
      geom_line( aes(x = roc4$FP[,2], y = roc4$TP[,2]),color = cols[4])+

      geom_line(aes(x=c(0,1), y=c(0,1)), color = "grey", linetype = "dashed" )+
      theme_light()+
      annotate("text",x = .7, y = .35, label = paste("AUC of ", var1," = ", auc1),color = cols[1])+
      annotate("text",x = .7, y = .25, label = paste("AUC of ", var2, " = ", auc2),color = cols[2])+
      annotate("text",x = .7, y = .15, label = paste("AUC of ", var3, " = ", auc3),color = cols[3])+
      annotate("text",x = .7, y = .05, label = paste("AUC of ", var4, " = ", auc4),color = cols[4])+
      scale_x_continuous(name  = "False Positive Rate")+
      scale_y_continuous(name = "True Positive Rate")+
      ggtitle(paste0(main, " = ", time_point, " month"))

  }

  p <- p + design_mytheme(axis_angle = 0, hjust = 0.5, axis_title_size = 1.7)
  # print(p)
  ggsave(p, filename = paste0(index,"-", main,"-ROC-time",".", fig.type),
         width = width ,height = height, path = path$folder_name)
  return(p)
}
