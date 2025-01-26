const { Filter } = require('./src/filterClasses');
const {URLRequest} = require('./src/url');
const {contentTypes} = require('./src/contentTypes');
const {defaultMatcher} = require('./src/matcher');

function main() {
  // const rules = [
  //   '||d2wlwbnaa4keje.cloudfront.net^$script,image',
  //   'm.youtube.com,music.youtube.com#$#override-property-read yt.ads.biscotti.lastId_ undefined',
  //   'studme.org#$#abort-on-property-read _0x5443',
  //   '-1688-wp-media/ads/',
  //   '!--fdsa-',
  //   'null',
  //   'google.com',
  // ];
  let rules = ["foos", "*bar", "bar$domain=example1.com", "@@foos"];
  const allFilters = rules.map(rule => new Filter.fromText(rule));
  console.log(allFilters.map(x => x.type));

  console.log('-----------------------------');
  const filters = allFilters.filter(x => x.type == 'blocking');

  for (const filter of filters) {
    defaultMatcher.add(filter);
  }

  const searchResult = defaultMatcher.search("http://example.com/foos/bars", contentTypes.IMAGE, 'example1.com', null, false);
  console.log('searchResult: ', searchResult);

  
   // checkSearch(filters, "http://example.com/foos", "IMAGE", "example.com", null, false, "all", {blocking: ["foos"], allowing: ["@@foos"]});
  // checkSearch(filters, "http://example.com/foos", contentTypes.IMAGE, "example.com");
  // console.log("-----------------------------");
  // checkSearch(filters, "http://example.com/bar/foos.jpg", contentTypes.IMAGE, "example.com");
  // const req = URLRequest.from("http://example.com/foos");
  // const blockingFilters = filters.filter(x => x.type == 'blocking');
  // blockingFilters.forEach(filter => {
  //   const matchResult = filter.matches(req, contentTypes.IMAGE, "example.com");
  //   console.log(filter, matchResult);
  // });
  // console.log(filters);
}

function checkSearch(filters, url, contentType, domain) {
  const req = URLRequest.from(url);
  filters.forEach(filter => {
    const matchResult = filter.matches(req, contentType, domain);
    console.log(filter, matchResult);
  });
}

main();
