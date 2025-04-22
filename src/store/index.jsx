import { createGlobalState } from "react-hooks-global-state";

// in variables me hum dusri files se data store krte h aur aur jab kisi aur file ko us data ki jrurt hoti h toh vo us data ko yaha se access kr leti h.
const { setGlobalState, useGlobalState, getGlobalState } = createGlobalState({
    modal: 'scale-0',
    updateModal: 'scale-0',
    showModal: 'scale-0',
    alert: { show: false, msg: '', color: '' },
    loading: { show: false, msg: '' },
    // jab bhi user metamask k account se connect hoga ya account change hoga metamask me toh isme address store ho jaiye ga.
    connectedAccount: '',
    nft: null,
    // isme nfts store krdege jab bhi vo mint hogi.
    nfts: [],
    // jab bhi nft buy hogi toh isme transactions store hoge.
    transactions: [],
    contract: null
})

const setAlert = (msg, color = 'green') => {
    setGlobalState('loading', false)
    setGlobalState('alert', { show: true, msg, color })
    setTimeout(() => {
      setGlobalState('alert', { show: false, msg: '', color })
    }, 6000)
  }

const setLoadingMsg = (msg) => {
    const loading = getGlobalState('loading')
    setGlobalState('loading', { ...loading, msg })
}

const truncate = (text, startChars, endChars, maxLength) => {
  if(text.length > maxLength){
    var start = text.substring(0, startChars);
    var end = text.substring(text.length - endChars, text.length);
    while (start.length + end.length < maxLength){
      start = start + '.';
    }
    return start + end;
  }
  return text;
}

export { setGlobalState, useGlobalState, getGlobalState, setLoadingMsg, setAlert, truncate }