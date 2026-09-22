// Build-time only. Translates static source text, never user or Firestore data.
const fs = require('fs');
const path = require('path');
const root = path.resolve(__dirname, '../..');
const dir = path.join(root, 'assets/i18n');
fs.mkdirSync(dir, {recursive:true});
function files(folder) {
  return fs.readdirSync(folder, {withFileTypes:true}).flatMap(e => e.isDirectory() ? files(path.join(folder,e.name)) : e.name.endsWith('.dart') ? [path.join(folder,e.name)] : []);
}
// Small Dart string scanner, including nested strings inside interpolations.
function readString(s, start, collect) {
  const quote=s[start]; let i=start+1, value='', args=0;
  while(i<s.length) {
    if(s[i]===quote) return {end:i+1,value};
    if(s[i]==='\\') {
      const c=s[++i]; value+=({n:'\n',r:'\r',t:'\t'}[c] ?? c); i++; continue;
    }
    if(s[i]==='$') {
      if(s[i+1]==='{') {
        i+=2; let depth=1;
        while(depth && i<s.length) {
          if(s[i]==="'" || s[i]==='"') { i=readString(s,i,false).end; continue; }
          if(s[i]==='{') depth++; if(s[i]==='}') depth--; i++;
        }
      } else {
        i++; while(i<s.length && /[A-Za-z0-9_]/.test(s[i])) i++;
      }
      value+=`{${args++}}`; continue;
    }
    value+=s[i++];
  }
  throw Error('Unclosed string');
}
function extract(s) {
  const result=[];
  for(let i=0;i<s.length;) {
    if(s.slice(i,i+2)==='//') { const end=s.indexOf('\n',i); i=end<0?s.length:end+1; continue; }
    if(s.slice(i,i+2)==='/*') { i=s.indexOf('*/',i+2)+2; continue; }
    if(s[i]==="'" || s[i]==='"') { const item=readString(s,i,true); result.push(item.value); i=item.end; }
    else i++;
  }
  return result;
}
const sources=files(path.join(root,'lib')).filter(p=>!p.includes(path.sep+'l10n'+path.sep));
const overrides=JSON.parse(fs.readFileSync(path.join(__dirname,'overrides.json'),'utf8'));
const strings=[...new Set([...sources.flatMap(p=>extract(fs.readFileSync(p,'utf8'))),...Object.keys(overrides)])].filter(s=>
  /[A-Za-zÀ-ÿ]/.test(s) && /[ À-ÿ]|^[A-Z]/.test(s) &&
  !/^(package:|https?:|assets\/|\.\.\/|file:)/.test(s) && !s.endsWith('.dart') &&
  !/^[^ ]+@[^ ]+$/.test(s) && !/^#[0-9A-F]+$/i.test(s) && !s.includes('\\')
).sort();
fs.writeFileSync(path.join(dir,'pt.json'),JSON.stringify(Object.fromEntries(strings.map(s=>[s,s])),null,2)+'\n');
function tokens(s) { return (s.match(/\{\d+\}/g)||[]).sort().join(','); }
async function translate(text, lang) {
  for(let attempt=0;attempt<4;attempt++) {
    try {
      const url=new URL('https://translate.googleapis.com/translate_a/single');
      for(const [k,v] of Object.entries({client:'gtx',sl:'pt',tl:lang,dt:'t',q:text})) url.searchParams.set(k,v);
      const res=await fetch(url,{signal:AbortSignal.timeout(30000)});
      if(!res.ok) throw Error(`HTTP ${res.status}`);
      const json=await res.json();
      return json[0].map(part=>part[0]||'').join('');
    } catch(e) { if(attempt===3) throw e; await new Promise(r=>setTimeout(r,1000*(attempt+1))); }
  }
}
async function build(lang) {
  const output=path.join(dir,`${lang}.json`);
  const data=fs.existsSync(output)?JSON.parse(fs.readFileSync(output,'utf8')):{};
  for(const [key,values] of Object.entries(overrides)) data[key]=values[lang];
  fs.writeFileSync(output,JSON.stringify(data,null,2)+'\n');
  const pending=strings.filter(s=>!data[s]);
  let completed=0;
  while(pending.length) {
    const batch=[];let size=0;
    while(pending.length && size+pending[0].length<2200 && batch.length<25 && !pending[0].includes('\n')) {
      const item=pending.shift();batch.push(item);size+=item.length+1;
    }
    if(!batch.length) batch.push(pending.shift());
    const result=await translate(batch.join('\n'),lang);
    const lines=batch.length===1?[result]:result.split('\n');
    for(let i=0;i<batch.length;i++) {
      let value=lines.length===batch.length?lines[i].trim():await translate(batch[i],lang);
      if(tokens(value)!==tokens(batch[i])) value=await translate(batch[i],lang);
      if(tokens(value)!==tokens(batch[i])) throw Error(`Lost placeholders: ${batch[i]} => ${value}`);
      data[batch[i]]=value;
    }
    completed+=batch.length;
    fs.writeFileSync(output,JSON.stringify(data,null,2)+'\n');
    console.log(`${lang}: ${completed} translated, ${pending.length} remaining`);
  }
}
Promise.all(['en','es'].map(build)).catch(e=>{console.error(e);process.exitCode=1;});
