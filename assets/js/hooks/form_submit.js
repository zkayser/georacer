export const FormSubmit = {
  mounted() {
    const form = this.el.closest('form');
    this.el.addEventListener('click', () => {
      console.log('form submit button was pressed...');
      form.submit();
    });
  }
};