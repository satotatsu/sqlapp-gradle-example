FROM gradle:jdk25-alpine

RUN apk add --no-cache \
       graphviz \
       ttf-freefont \
       fontconfig

RUN mkdir -p html && chmod -R 755 html
ENTRYPOINT ["gradle"]
CMD ["generateHtml"]
