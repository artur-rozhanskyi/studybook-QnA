export default function errorsStr(errors) {
  let str = '';
  const capitalize = (s) => {
    if (typeof s !== 'string') return '';
    return s.charAt(0).toUpperCase() + s.slice(1);
  };
  Object.entries(errors).forEach((element) => {
    const name = (element[0].slice(0, 4) === 'form') ? element[0].slice(5) : element[0];
    str += `${capitalize(name)} ${element[1]}`;
  });
  return str;
}
