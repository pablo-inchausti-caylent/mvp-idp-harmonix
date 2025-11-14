import { makeStyles } from '@material-ui/core';

const useStyles = makeStyles({
  img: {
    width: '40px',
    height: 'auto',
  },
});

const LogoIcon = () => {
  const classes = useStyles();

  // Edited to use Sequoia Capital logo
  
  return (
    <img
      className={classes.img}
      src="/sequoia-logo.svg"
      alt="Sequoia Logo"
    />
  );
};

export default LogoIcon;
