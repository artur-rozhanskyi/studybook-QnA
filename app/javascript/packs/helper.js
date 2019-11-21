export default function errorsStr(errors) {
  let str = '';
  const capitalize = (s) => {
    if (typeof s !== 'string') return '';
    return s.charAt(0).toUpperCase() + s.slice(1);
  };
  Object.entries(errors).forEach((element) => {
    str += `${capitalize(element[0])} ${element[1]}`;
  });
  return str;
}
