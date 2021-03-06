## draw.leg.R

### Copyright (C) 2001-2005  Deepayan Sarkar <Deepayan.Sarkar@R-project.org>
###
### This file is part of the lattice library for R.
### It is made available under the terms of the GNU General Public
### License, version 2, or at your option, any later version,
### incorporated herein by reference.
###
### This program is distributed in the hope that it will be
### useful, but WITHOUT ANY WARRANTY; without even the implied
### warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
### PURPOSE.  See the GNU General Public License for more
### details.
###
### You should have received a copy of the GNU General Public
### License along with this program; if not, write to the Free
### Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
### MA 02111-1307, USA

## Slightly modified Version of draw.key {lattice 0.12-3}
## by Rene Locher <Rene.Locher@zhaw.ch>
## last revision: 09-08-04
## 3 new components added to list key: between.rows, between.title, adj.title



draw.leg <- function(key, draw = FALSE, vp = NULL)
{
    if (!is.list(key)) stop("key must be a list")

    max.length <- 0

    ## maximum of the `row-lengths' of the above
    ## components. There is some scope for confusion
    ## here, e.g., if col is specified in key as a
    ## length 6 vector, and then lines=list(lty=1:3),
    ## what should be the length of that lines column ?
    ## If 3, what happens if lines=list() ?
    ## (Strangely enough, S+ accepts lines=list()
    ## if col (etc) is NOT specified outside, but not
    ## if it is)

    is.characterOrExpression <- function (x) ##lor
      is.character(x) || is.expression(x)    ##lor

    rearrangeUnit <- function (x, pos, u) ##lor
      {
        if (length(x) == 1)
          u
        else if (pos == 1)
          unit.c(u, x[(pos + 1):length(x)])
        else if (pos == length(x))
          unit.c(x[1:(pos - 1)], u)
        else unit.c(x[1:(pos - 1)], u, x[(pos + 1):length(x)])
      } ##lor

    chooseFace <- function (fontface = NULL, font = 1) ##lor
      if (is.null(fontface)) font else fontface ##lor

    process.key <-
        function(between = 2,
                 align = TRUE,
                 title = NULL,
                 rep = TRUE,
                 background = trellis.par.get("background")$col,
                 border = FALSE,
                 transparent = FALSE,
                 columns = 1,
                 divide = 3,
                 between.columns = 3,
                 between.rows = 0.2,  ##lor
                 between.title = 0.2, ##lor
                 adj.title = 0.5,     ##lor
                 cex = 1,
                 cex.title = 1.5 * max(cex),
                 col = "black",
                 lty = 1,
                 lwd = 1,
                 font = 1,
                 fontface = NULL,
                 fontfamily = NULL,
                 pch = 8,
                 adj = 0,
                 type = "l",
                 size = 5,
                 angle = 0,
                 density = -1,
                 ...)
        {
            list(between = between,
                 align = align,
                 title = title,
                 rep = rep,
                 background = background,
                 border = border,
                 transparent = transparent,
                 columns = columns,
                 divide = divide,
                 between.columns = between.columns,
                 between.rows = between.rows,    ##lor
                 between.title =  between.title, ##lor
                 adj.title =  adj.title,         ##lor
                 cex = cex,
                 cex.title = cex.title,
                 col = col,
                 lty = lty,
                 lwd = lwd,
                 font = font,
                 fontface = fontface,
                 fontfamily = fontfamily,
                 pch = pch,
                 adj = adj,
                 type = type,
                 size = size,
                 angle = angle,
                 density = density,
                 ...)
        }
    size.rect <- 0.6 ##lor defines dimensions of rectangles in key relative to strheight
    fontsize.points <- trellis.par.get("fontsize")$points
    key <- do.call("process.key", key)

    key.length <- length(key)
    key.names <- names(key)    # Need to update

    if (is.logical(key$border))
        key$border <-
            if (key$border) "black"
            else "transparent"

    components <- list()

    for(i in 1:key.length) {

        curname <- pmatch(key.names[i], c("text", "rectangles", "lines", "points"))

        if (is.na(curname)) {
            ;## do nothing
        }
        else if (curname == 1) { # "text"
            if (!(is.characterOrExpression(key[[i]][[1]])))
                stop("first component of text has to be vector of labels")
            pars <- list(labels = key[[i]][[1]],
                         col = key$col,
                         adj = key$adj,
                         cex = key$cex,
                         font = key$font,
                         fontface = key$fontface,
                         fontfamily = key$fontfamily)
            key[[i]][[1]] <- NULL
            pars[names(key[[i]])] <- key[[i]]

            tmplen <- length(pars$labels)
            for (j in 1:length(pars))
                if (is.character(pars))
                    pars[[j]] <- rep(pars[[j]], length.out = tmplen)

            max.length <- max(max.length, tmplen)
            components[[length(components)+1]] <-
                list(type = "text", pars = pars, length = tmplen)

        }
        else if (curname == 2) { # "rectangles"

            pars <- list(col = key$col,
                         size = key$size,
                         angle = key$angle,
                         density = key$density)

            pars[names(key[[i]])] <- key[[i]]

            tmplen <- max(unlist(lapply(pars,length)))
            max.length <- max(max.length, tmplen)
            components[[length(components)+1]] <-
                list(type = "rectangles", pars = pars, length = tmplen)

        }
        else if (curname == 3) { # "lines"

            pars <- list(col = key$col,
                         size = key$size,
                         lty = key$lty,
                         cex = key$cex,
                         pch = key$pch,
                         lwd = key$lwd,
                         type = key$type)

            pars[names(key[[i]])] <- key[[i]]

            tmplen <- max(unlist(lapply(pars,length)))
            max.length <- max(max.length, tmplen)
            components[[length(components)+1]] <-
                list(type = "lines", pars = pars, length = tmplen)

        }
        else if (curname == 4) { # "points"

            pars <- list(col = key$col,
                         cex = key$cex,
                         pch = key$pch,
                         font = key$font,
                         fontface = key$fontface,
                         fontfamily = key$fontfamily)

            pars[names(key[[i]])] <- key[[i]]

            tmplen <- max(unlist(lapply(pars,length)))
            max.length <- max(max.length, tmplen)
            components[[length(components)+1]] <-
                list(type = "points", pars = pars, length = tmplen)

        }
    }



    number.of.components <- length(components)
    ## number of components named one of "text",
    ## "lines", "rectangles" or "points"
    if (number.of.components == 0)
        stop("Invalid key, need at least one component named lines, text, rect or points")

    ## The next part makes sure all components have same length,
    ## except text, which should be as long as the number of labels

    ## Update (9/11/2003): but that doesn't always make sense --- Re:
    ## r-help message from Alexander.Herr@csiro.au (though it seems
    ## that's S+ behaviour on Linux at least). Each component should
    ## be allowed to have its own length (that's what the lattice docs
    ## suggest too, don't know why). Anyway, I'm adding a rep = TRUE
    ## argument to the key list, which controls whether each column
    ## will be repeated as necessary to have the same length.


    for (i in 1:number.of.components)
        if (components[[i]]$type != "text") {
            components[[i]]$pars <-
                lapply(components[[i]]$pars, rep,
                       length.out = if (key$rep) max.length
                       else components[[i]]$length)
            if (key$rep) components[[i]]$length <- max.length
        }
        else{
            ## NB: rep doesn't work with expressions of length > 1
            components[[i]]$pars <-
                c(components[[i]]$pars[1],
                  lapply(components[[i]]$pars[-1], rep,
                         length = components[[i]]$length))
        }

    column.blocks <- key$columns
    rows.per.block <- ceiling(max.length/column.blocks)

    if (column.blocks > max.length) warning("not enough rows for columns")

    key$between <- rep(key$between, length.out = number.of.components)


    if (key$align) {

        ## Setting up the layout


	## The problem of allocating space for text (character strings
	## or expressions) is dealt with as follows:

	## Each row and column will take exactly as much space as
	## necessary. As steps in the construction, a matrix
	## textMatrix (of same dimensions as the layout) will contain
	## either 0, meaning that entry is not text, or n > 0, meaning
	## that entry has the text given by textList[[n]], where
	## textList is a list consisting of character strings or
	## expressions.



        n.row <- rows.per.block + 1
        n.col <- column.blocks * (1 + 3 * number.of.components) - 1

	textMatrix <- matrix(0, n.row, n.col)
	textList <- list()
	textCex <- numeric(0)

        heights.x <- rep(1, n.row)
        heights.units <- rep("lines", n.row)
        heights.data <- vector("list", n.row)

        if (length(key$title) > 0)
        {
            stopifnot(length(key$title) == 1,
                      is.characterOrExpression(key$title))
            ## heights.x[1] <- 1.2 * key$cex.title
            heights.x[1] <- (1+key$between.title) * key$cex.title  ##lor
            heights.units[1] <- "strheight"
            heights.data[[1]] <- key$title
        }
        else heights.x[1] <- 0


        widths.x <- rep(key$between.columns, n.col)
        widths.units <- rep("strwidth", n.col)
        widths.data <- as.list(rep("o", n.col))



        for (i in 1:column.blocks) {
            widths.x[(1:number.of.components-1)*3+1 +
                     (i-1)*3*number.of.components + i-1] <-
                         key$between/2

            widths.x[(1:number.of.components-1)*3+1 +
                     (i-1)*3*number.of.components + i+1] <-
                         key$between/2
        }


	index <- 1

        for (i in 1:number.of.components) {

            cur <- components[[i]]

            id <- (1:column.blocks - 1) *
                (number.of.components * 3 + 1) + i * 3 - 1

            if (cur$type == "text") {

                for (j in 1:cur$length) {

                    colblck <- ceiling(j / rows.per.block)

                    xx <- (colblck - 1) *
                        (number.of.components * 3 + 1) + i * 3 - 1

                    yy <- j %% rows.per.block + 1
                    if (yy == 1) yy <- rows.per.block + 1

		    textMatrix[yy, xx] <- index
		    textList <- c(textList, list(cur$pars$labels[j]) )
		    textCex <- c(textCex, cur$pars$cex[j])
  		    index <- index + 1

		}


            } ## FIXME: do the same as above for those below
            else if (cur$type == "rectangles") {
                widths.x[id] <- max(cur$pars$size)
            }
            else if (cur$type == "lines") {
                widths.x[id] <- max(cur$pars$size)
            }
            else if (cur$type == "points") {
                widths.x[id] <- max(cur$pars$cex)
            }
        }


        ## Need to adjust the heights and widths

        ## adjusting heights
        heights.insertlist.position <- 0
        heights.insertlist.unit <- unit(1, "null")

        for (i in 1:n.row) {
            textLocations <- textMatrix[i,]
            textLocations <- textLocations[textLocations>0]
            ## if (any(textLocations))
            if (length(textLocations)) {

                strbar <- textList[textLocations]
                heights.insertlist.position <- c(heights.insertlist.position, i)
                heights.insertlist.unit <-
                    unit.c(heights.insertlist.unit,
                           ##unit(.2, "lines") + max(unit(textCex[textLocations], "strheight", strbar)))
                           unit(key$between.rows, "lines") + max(unit(textCex[textLocations], "strheight", strbar)))  ##lor
            }
        }


        layout.heights <- unit(heights.x, heights.units, data=heights.data)
        if (length(heights.insertlist.position)>1)
            for (indx in 2:length(heights.insertlist.position))
                layout.heights <-
                    rearrangeUnit(layout.heights, heights.insertlist.position[indx],
                                  heights.insertlist.unit[indx])





        ## adjusting widths
        widths.insertlist.position <- 0
        widths.insertlist.unit <- unit(1, "null")




        for (i in 1:n.col) {
            textLocations <- textMatrix[,i]
            textLocations <- textLocations[textLocations>0]
            ##  if (any(textLocations))
            if (length(textLocations)) {
                strbar <- textList[textLocations]
                widths.insertlist.position <-
                    c(widths.insertlist.position, i)
                widths.insertlist.unit <-
                    unit.c(widths.insertlist.unit,
                           max(unit(textCex[textLocations],
                                    "strwidth", strbar)))
            }
        }


        layout.widths <- unit(widths.x, widths.units, data=widths.data)
        if (length(widths.insertlist.position)>1)
            for (indx in 2:length(widths.insertlist.position))
                layout.widths <-
                    rearrangeUnit(layout.widths, widths.insertlist.position[indx],
                                  widths.insertlist.unit[indx])


        key.layout <- grid.layout(nrow = n.row, ncol = n.col,
                                  widths = layout.widths,
                                  heights = layout.heights,
                                  respect = FALSE)

        ## OK, layout set up, now to draw the key - no


        key.gf <- frameGrob(layout = key.layout, vp = vp)

        if (!key$transparent)
            key.gf <- placeGrob(key.gf,
                                rectGrob(gp = gpar(fill = key$background,
                                                   col = key$border)),
                                row = NULL, col = NULL)
        else
            key.gf <- placeGrob(key.gf,
                                rectGrob(gp=gpar(col=key$border)),
                                row = NULL, col = NULL)

        ## Title
        if (!is.null(key$title))
            key.gf <- placeGrob(key.gf,
                                textGrob(x=key$adj.title,                        ##lor
                                         just = c(                               ##lor
                                           if (key$adj.title == 1) "right"       ##lor
                                           else if (key$adj.title == 0) "left"   ##lor
                                           else "center",                        ##lor
                                           "center"),                            ##lor
                                         label = key$title, gp = gpar(cex = key$cex.title)),
                                row=1, col = NULL)



        for (i in 1:number.of.components)
        {
            cur <- components[[i]]
            for (j in 1:cur$length)
            {
                colblck <- ceiling(j / rows.per.block)
                xx <- (colblck - 1) *
                    (number.of.components*3 + 1) + i*3 - 1
                yy <- j %% rows.per.block + 1
                if (yy == 1) yy <- rows.per.block + 1
                if (cur$type == "text") {

                    key.gf <- placeGrob(key.gf,
                                        textGrob(x = cur$pars$adj[j],
                                                 just = c(
                                                 if (cur$pars$adj[j] == 1) "right"
                                                 else if (cur$pars$adj[j] == 0) "left"
                                                 else "center",
                                                 "center"),
                                                 label = cur$pars$labels[j],
                                                 gp =
                                                 gpar(col = cur$pars$col[j],
                                                      fontfamily = cur$pars$fontfamily[j],
                                                      fontface = chooseFace(cur$pars$fontface[j], cur$pars$font[j]),
                                                      cex = cur$pars$cex[j])),
                                        row = yy, col = xx)

                }
                else if (cur$type == "rectangles") {
                    key.gf <- placeGrob(key.gf,
                                        ##rectGrob(width = cur$pars$size[j]/max(cur$pars$size), ##lor
                                        rectGrob(width = size.rect*cur$pars$size[j]/max(cur$pars$size), ##lor
                                                 height = unit(size.rect,"lines"), ##lor
                                                 ## centred, unlike Trellis, due to aesthetic reasons !
                                                 gp = gpar(fill = cur$pars$col[j])),
                                        row = yy, col = xx)

                    ## FIXME: Need to make changes to support angle/density
                }
                else if (cur$type == "lines") {
                    if (cur$pars$type[j] == "l") {
                        key.gf <-
                            placeGrob(key.gf,
                                      linesGrob(x = c(0,1) * cur$pars$size[j]/max(cur$pars$size),

                                                ## ^^ FIXME: this
                                                ## should be centered
                                                ## as well, but since
                                                ## the chances that
                                                ## someone would
                                                ## actually use this
                                                ## feature are
                                                ## astronomical, I'm
                                                ## leaving that for
                                                ## later.

                                                y = c(.5, .5),
                                                gp = gpar(col = cur$pars$col[j],
                                                lty = cur$pars$lty[j],
                                                lwd = cur$pars$lwd[j])),
                                  row = yy, col = xx)
                    }
                    else if (cur$pars$type[j] == "p") {
                        key.gf <-
                            placeGrob(key.gf,
                                      pointsGrob(x=.5, y=.5,
                                                 gp =
                                                 gpar(col = cur$pars$col[j], cex = cur$pars$cex[j],
                                                      fontfamily = cur$pars$fontfamily[j],
                                                      fontface = chooseFace(cur$pars$fontface[j], cur$pars$font[j]),
                                                      fontsize = fontsize.points),
                                                 pch = cur$pars$pch[j]),
                                      row = yy, col = xx)
                    }
                    else { # if (cur$pars$type[j] == "b" or "o") -- not differentiating
                        key.gf <-
                            placeGrob(key.gf,
                                      linesGrob(x = c(0,1) * cur$pars$size[j]/max(cur$pars$size),

                                                ## ^^ this should be
                                                ## centered as well,
                                                ## but since the
                                                ## chances that
                                                ## someone would
                                                ## actually use this
                                                ## feature are
                                                ## astronomical, I'm
                                                ## leaving that for
                                                ## later.

                                                y = c(.5, .5),
                                                gp = gpar(col = cur$pars$col[j],
                                                lty = cur$pars$lty[j],
                                                lwd = cur$pars$lwd[j])),
                                      row = yy, col = xx)

                        if (key$divide > 1)
                        {
                            key.gf <-
                                placeGrob(key.gf,
                                          pointsGrob(x = (1:key$divide-1)/(key$divide-1),
                                                     y = rep(.5, key$divide),
                                                     gp =
                                                     gpar(col = cur$pars$col[j],
                                                          cex = cur$pars$cex[j],
                                                          fontfamily = cur$pars$fontfamily[j],
                                                          fontface = chooseFace(cur$pars$fontface[j], cur$pars$font[j]),
                                                          fontsize = fontsize.points),
                                                     pch = cur$pars$pch[j]),
                                          row = yy, col = xx)
                        }
                        else if (key$divide == 1)
                        {
                            key.gf <-
                                placeGrob(key.gf,
                                          pointsGrob(x = 0.5,
                                                     y = 0.5,
                                                     gp =
                                                     gpar(col = cur$pars$col[j],
                                                          cex = cur$pars$cex[j],
                                                          fontfamily = cur$pars$fontfamily[j],
                                                          fontface = chooseFace(cur$pars$fontface[j], cur$pars$font[j]),
                                                          fontsize = fontsize.points),
                                                     pch = cur$pars$pch[j]),
                                          row = yy, col = xx)
                        }
                    }
                }
                else if (cur$type == "points") {
                    key.gf <- placeGrob(key.gf,
                                        pointsGrob(x=.5, y=.5,
                                                   gp =
                                                   gpar(col = cur$pars$col[j], cex = cur$pars$cex[j],
                                                        fontfamily = cur$pars$fontfamily[j],
                                                        fontface = chooseFace(cur$pars$fontface[j], cur$pars$font[j]),
                                                        fontsize = fontsize.points),
                                                   pch = cur$pars$pch[j]),
                                        row = yy, col = xx)
                }

            }

        }

    }
    else stop("sorry, align=F not supported (yet ?)")


    if (draw)
        grid.draw(key.gf)

    key.gf
} ## drawleg.R
