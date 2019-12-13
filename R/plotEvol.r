#'Plots the impact of increasing missing data on RGCCA
#' @param listFinale A list resulting of naEvolution
#' @param output ="rv": Can be also "a" for correlations between axes, "bm" for the percent of similar biomarkers, "rvComplete" if the RV is calculated only on complete dataset, or "rmse" for Root Mean Squares Error.
#' @param fileName =NULL name of the file where the plot is saved
#' @param ylim =c(0.8,1) y limits
#' @param block ="all" or a number indicating the position of the chosen block in the initial list
#' @param barType ="sd" or "stderr". Indicates which error bar to build
#' @param namePlot =NULL Name of the file
#' @param width =480 width of the saved file
#' @param height =480 height of the saved file
#' @param names.arg  renaming the methods
#' @param main title of the graphic
#' @examples 
#' set.seed(42);X1=matrix(rnorm(350),70,5);X2=matrix(rnorm(280),70,4)
#' A=list(X1,X2)
#' listResults=naEvolution(A=A,prctNA=c(0.1,0.2,0.3,0.4),
#' listMethods=c("mean","complete","nipals","knn4"))
#' plotEvol(listFinale=listResults,ylim=c(0,1),output="a")
#' @importFrom grDevices graphics.off
#' @export
plotEvol=function(listFinale,output="rv",fileName=NULL,ylim=NULL,block="all",barType="sd",namePlot=NULL,width=480,height=480,names.arg=NULL,main=NULL)
{ #output : "rv", "pct" ou "a"
  #barType="sd" or "stdErr"
  if(is.null(namePlot)){namePlot=output}
  graphics.off()
  if(!is.null(fileName)){png(paste(fileName,".png",sep=""),width=width,height=height)}
  nameData= names(listFinale)
  abscisse=as.numeric(nameData)
  par(las=1)
  J=length(listFinale[[1]][[1]][[1]][[1]]) #nblock
  if(block=="all"&&J<5){ split.screen(c(2,2));toPlot=1:J}else{toPlot=block:block}
  namesMethod=as.character(names(listFinale[[1]][[1]]))
  #colMethod=rainbow(5)[1:length(namesMethod)]
  colMethod=c("cornflowerblue","chocolate1","chartreuse3","red","blueviolet","darkturquoise","darkgoldenrod1","coral","bisque4","darkorchid1","deepskyblue1")[1:length(namesMethod)]
  nMeth=0:length(namesMethod)
  pas=1/length(namesMethod)
  names(colMethod)=names(nMeth)=namesMethod
  moyenne=list()
  ecartType=list()
  ymin=rep(1,length(toPlot));names(ymin)=toPlot; print(ymin)
  ymax=rep(0,length(toPlot));names(ymax)=toPlot;print(ymax)
  for(j in toPlot)
  { 
    moyenne[[j]]=ecartType[[j]]=matrix(NA,length(abscisse),length(namesMethod));
    rownames(moyenne[[j]])=rownames(ecartType[[j]])=abscisse
    colnames(moyenne[[j]])=colnames(ecartType[[j]])=namesMethod
    for(da in 1:length(abscisse))
    {
      for(rg in namesMethod)
      {  
      
        result=sapply(listFinale[[da]],function(x){return(x[[rg]][[output]][j])})
      
        moyenne[[j]][da,rg]=mean(result)
        if(!barType %in% c("sd","stderr")){ecartType[[j]][da,rg]=0}
        if(barType=="sd"){ecartType[[j]][da,rg]=sd(result)}
        if(barType=="stderr"){ecartType[[j]][da,rg]=sd(result)/sqrt(length(result))}
        if(length(toPlot)>1)
        {
            ymin[j]=min(ymin[j],min(moyenne[[j]][da,rg]-ecartType[[j]][da,rg]))
            ymax[j]=max(ymax[j],max(moyenne[[j]][da,rg]+ecartType[[j]][da,rg]))
        }
        else
        {
            ymin=min(ymin,min(moyenne[[j]][da,rg]-ecartType[[j]][da,rg]))
           ymax=max(ymax,max(moyenne[[j]][da,rg]+ecartType[[j]][da,rg]))
        }
       
      }
    }
  }
  print("y")
  print(ymin)
  print(ymax)
  # Plotting results
  for(j in toPlot)
  { 
     if(length(toPlot)>1)
     {
         if(is.null(ylim)){Ylim=c(ymin[j],ymax[j])}else{Ylim=ylim}
     }
     if(length(toPlot)==1)
     {
         if(is.null(ylim)){Ylim=c(ymin,ymax)}else{Ylim=ylim}
     }
      print("y")
      print(ymin[j])
      print(ymax[j])
      print(ylim)
    if(block=="all"){screen(j)}
    par(mar=c(5, 4, 4, 2) + 0.1)
    par(mgp=c(3,1,0))
    if(is.null(main)){title=paste(namePlot,": Block",j)}else{title=main}
    par(mar=c(3,3,1,1))
    plot(NULL,main=title,xlim=c(0,length(abscisse)),ylim=Ylim,xlab="Proportion of missing values",ylab="",bty="n",xaxt="n")
    axis(side = 1,col="grey",line=0,at=-0.5+1:length(abscisse),labels=abscisse)
    
    axis(side = 2,col="grey",line=0)
    rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col = 
           "#e9ebec",border="#e9ebec")
    # grid(nx = NULL, ny = NULL, col = "white", lty = "dotted",  lwd = par("lwd"), equilogs = TRUE)
    
    for(da in 1:length(abscisse))
    {
      abline(v=da-1,col="dark grey",lty=2)
      for(rg in namesMethod)
      {
        if(!(rg=="complete"&&output=="rv"))
        {
        points(da-1+pas*nMeth[rg]+pas/2,moyenne[[j]][da,rg],pch=16,col=colMethod[rg])
        segments(da-1+pas*nMeth[rg]+pas/2,moyenne[[j]][da,rg]-ecartType[[j]][da,rg],da-1+pas*nMeth[rg]+pas/2,moyenne[[j]][da,rg]+ecartType[[j]][da,rg],col=colMethod[rg])
        }     
      }
    }
    abline(v=da+pas*max(nMeth),col="dark grey",lty=2)
  }
  # Plotting legend
  if(is.null(names.arg)||length(names.arg)!=length(namesMethod)){leg=namesMethod}else{leg=names.arg}
  if(block=="all")
  {
    screen(4)
    legend("center",legend=leg,fill=colMethod,box.lwd=0)
  }
  if(is.numeric(block))
  {
    legend("topleft",legend=leg,fill=colMethod,box.lwd=0)
  }
  if(!is.null(fileName)){dev.off()}
}
